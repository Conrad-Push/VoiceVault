import 'package:flutter/material.dart';
import '../services/local_file_service.dart';
import '../widgets/audioManagement/advanced_audio_recorder.dart';
import '../widgets/interfaceElements/app_header.dart';
import '../widgets/connectionStatus/network_status_banner.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const NetworkStatusBanner(),
              ScreenTitle(title: 'Nagrywanie - ${widget.recordingTitle}'),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(flex: 2, child: _buildContent()),
                    Expanded(
                      flex: 1,
                      child: _filePath == null
                          ? const Center(child: CircularProgressIndicator())
                          : AdvancedAudioRecorder(filePath: _filePath!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
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
                    onPressed: null,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Dalej',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    if (_filePath != null &&
        await LocalFileService.instance.fileExists(_filePath!)) {
      try {
        await LocalFileService.instance.deleteFile(_filePath!);
      } catch (e) {
        debugPrint('Error deleting temporary file: $e');
      }
    }
  }
}
