import 'package:flutter/material.dart';
import '../../services/local_file_service.dart';
import 'app_audio_player.dart';
import 'app_audio_recorder.dart';

class AdvancedAudioRecorder extends StatefulWidget {
  final String filePath;
  final VoidCallback onRecordingSaved;
  final VoidCallback onRecordingReset;
  final ValueChanged<Duration?> onDurationChanged;

  const AdvancedAudioRecorder({
    super.key,
    required this.filePath,
    required this.onRecordingSaved,
    required this.onRecordingReset,
    required this.onDurationChanged,
  });

  @override
  State<AdvancedAudioRecorder> createState() => _AdvancedAudioRecorderState();
}

class _AdvancedAudioRecorderState extends State<AdvancedAudioRecorder> {
  late Future<bool> _fileExists;

  @override
  void initState() {
    super.initState();
    _checkFileExists();
  }

  void _checkFileExists() {
    _fileExists = Future.delayed(
      const Duration(seconds: 1),
      () => LocalFileService.instance.fileExists(widget.filePath),
    ).then((value) => value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleRecordAgain() async {
    try {
      await LocalFileService.instance.deleteFile(widget.filePath);
      final fileExists =
          await LocalFileService.instance.fileExists(widget.filePath);

      if (!fileExists) {
        widget.onRecordingReset();
        debugPrint('File deleted successfully: ${widget.filePath}');
      } else {
        debugPrint(
            'File still exists after deletion attempt: ${widget.filePath}');
      }
    } catch (e) {
      debugPrint('Error while deleting file: $e');
    } finally {
      setState(() => _checkFileExists());
    }
  }

  void _onRecordingComplete() async {
    try {
      final fileExists =
          await LocalFileService.instance.fileExists(widget.filePath);
      if (fileExists) {
        widget.onRecordingSaved();
        debugPrint('Recording completed and file saved: ${widget.filePath}');
      } else {
        debugPrint(
            'Recording completed but file does not exist: ${widget.filePath}');
      }
      setState(() => _checkFileExists());
    } catch (e) {
      debugPrint('Error verifying file existence: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<bool>(
        future: _fileExists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Błąd: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return snapshot.data == true
              ? AppAudioPlayer(
                  filePath: widget.filePath,
                  onRecordAgain: _handleRecordAgain,
                  onDurationChanged: widget.onDurationChanged,
                )
              : AppAudioRecorder(
                  filePath: widget.filePath,
                  onRecordingComplete: _onRecordingComplete,
                );
        },
      ),
    );
  }
}
