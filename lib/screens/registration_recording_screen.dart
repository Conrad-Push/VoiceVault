import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';
import '../services/local_file_service.dart';
import '../widgets/audioManagement/advanced_audio_recorder.dart';
import '../widgets/interfaceElements/app_header.dart';
import '../widgets/connectionStatus/network_status_banner.dart';
import '../widgets/interfaceElements/loading_modal.dart';
import '../widgets/interfaceElements/screen_title.dart';
import '../widgets/connectionStatus/connection_icon.dart';
import '../widgets/interfaceElements/custom_modal.dart';
import '../utils/constants.dart';
import '../widgets/registrationContents/individual_sample_content.dart';
import '../widgets/registrationContents/individual_password_content.dart';
import '../widgets/registrationContents/shared_password_content.dart';

class RegistrationRecordingScreen extends StatefulWidget {
  final String userId;
  final String recordingType;
  final String recordingTitle;

  const RegistrationRecordingScreen({
    super.key,
    required this.userId,
    required this.recordingType,
    required this.recordingTitle,
  });

  @override
  State<RegistrationRecordingScreen> createState() =>
      _RegistrationRecordingScreenState();
}

class _RegistrationRecordingScreenState
    extends State<RegistrationRecordingScreen> {
  String? _filePath;
  bool _isRecordingSaved = false;
  int? _audioDuration;

  @override
  void initState() {
    super.initState();
    _initializeFilePath();
  }

  Future<void> _initializeFilePath() async {
    try {
      final filePath = await LocalFileService.instance.createFilePath(
        widget.userId,
        widget.recordingType,
        widget.recordingTitle,
      );
      setState(() => _filePath = filePath);
      debugPrint('File path generated: $filePath');
    } catch (e) {
      debugPrint('Error generating file path: $e');
    }
  }

  @override
  void dispose() async {
    super.dispose();
    if (_filePath != null) {
      try {
        if (await LocalFileService.instance.fileExists(_filePath!)) {
          await LocalFileService.instance.deleteFile(_filePath!);
        }
      } catch (e) {
        debugPrint('Error deleting temporary file: $e');
      }
    }
  }

  void _showNoConnectionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Problem z siecią',
          description:
              'Funkcjonalność aplikacji ograniczona z powodu braku dostępu do Internetu.',
          icon: Icons.wifi_off,
          iconColor: Colors.red,
          closeButtonLabel: 'OK',
          onClosePressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _showCancelModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CustomModal(
        title: 'Przerwanie nagrywania',
        description:
            'Jeśli opuścisz ekran, cały postęp zostanie utracony. Czy na pewno chcesz kontynuować?',
        icon: Icons.warning,
        iconColor: Colors.orange,
        closeButtonLabel: 'Nie',
        onClosePressed: () => Navigator.of(context).pop(),
        actionButtonLabel: 'Tak',
        actionButtonColor: Colors.red,
        onActionPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CustomModal(
        title: 'Błąd',
        description: 'Nie udało się przesłać pliku: $errorMessage',
        icon: Icons.error,
        iconColor: Colors.red,
        closeButtonLabel: 'OK',
        onClosePressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _uploadFileAndSaveMetadata(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingModal(
        title: 'Przesyłanie pliku',
        description: 'Trwa przesyłanie nagrania...',
        icon: Icons.cloud_upload,
        iconColor: Colors.blue,
      ),
    );
    String? uploadedFileName;

    try {
      uploadedFileName = await LocalFileService.instance
          .generateFileName(widget.recordingType, widget.recordingTitle);

      final downloadUrl = await StorageService.instance.uploadAudioFile(
        file: File(_filePath!),
        userId: widget.userId,
        recordingType: widget.recordingType,
        recordingTitle: widget.recordingTitle,
      );

      await FirestoreService.instance.addRecording(
        userId: widget.userId,
        type: widget.recordingType,
        filePath: downloadUrl,
        uploadedAt: Timestamp.now(),
        duration: _audioDuration ?? 0,
        recordingTitle: widget.recordingTitle,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Błąd przesyłania pliku: $e');

      if (uploadedFileName != null) {
        try {
          await StorageService.instance.deleteAudioFile(
            userId: widget.userId,
            recordingType: widget.recordingType,
            recordingTitle: widget.recordingTitle,
          );
          debugPrint('Niepowodzenie operacji: plik usunięty ze Storage.');
        } catch (deletionError) {
          debugPrint('Błąd podczas usuwania pliku ze Storage: $deletionError');
        }

        try {
          await FirestoreService.instance.deleteRecording(
            userId: widget.userId,
            recordingTitle: widget.recordingTitle,
          );
          debugPrint('Niepowodzenie operacji: dokument usunięty z Firestore.');
        } catch (deletionError) {
          debugPrint('Błąd podczas usuwania pliku z Firestore: $deletionError');
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorModal(context, e.toString());
      }
    }
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null) {
      setState(() {
        _audioDuration = duration.inSeconds;
      });
    }
  }

  void _handleNext() {
    final isConnected = context.read<ConnectivityProvider>().isConnected;
    if (!isConnected) {
      _showNoConnectionModal(context);
      return;
    }

    debugPrint("Proceeding to the next step with file: $_filePath");
    _uploadFileAndSaveMetadata(context);
  }

  Widget _buildContent() {
    switch (widget.recordingType) {
      case 'individualSample':
        return IndividualSampleContent(recordingTitle: widget.recordingTitle);
      case 'individualPassword':
        return IndividualPasswordContent(recordingTitle: widget.recordingTitle);
      case 'sharedPassword':
        return SharedPasswordContent(recordingTitle: widget.recordingTitle);
      default:
        return const Center(child: Text('Nieznany typ nagrania'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        automaticallyImplyLeading: false,
        title: 'Voice Vault',
        trailing: ConnectionIcon(),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const NetworkStatusBanner(),
            ScreenTitle(title: 'Nagrywanie - ${widget.recordingTitle}'),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Expanded(flex: 2, child: _buildContent()),
                    Expanded(
                      flex: 1,
                      child: _filePath == null
                          ? const Center(child: CircularProgressIndicator())
                          : AdvancedAudioRecorder(
                              filePath: _filePath!,
                              onRecordingSaved: () {
                                setState(() => _isRecordingSaved = true);
                              },
                              onRecordingReset: () {
                                setState(() => _isRecordingSaved = false);
                              },
                              onDurationChanged: _onDurationChanged,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _showCancelModal(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Anuluj',
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                  ElevatedButton(
                    onPressed: _isRecordingSaved ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A7D9A)),
                    child: const Text('Dalej',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
