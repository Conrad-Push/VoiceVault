import 'package:flutter/material.dart';
import '../../services/local_file_service.dart';
import 'app_audio_player.dart';
import 'app_audio_recorder.dart';

class AdvancedAudioRecorder extends StatefulWidget {
  final String filePath;

  const AdvancedAudioRecorder({
    super.key,
    required this.filePath,
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

  Future<void> _handleRecordAgain() async {
    try {
      await LocalFileService.instance.deleteFile(widget.filePath);
      setState(() => _checkFileExists());
      debugPrint('Plik został pomyślnie usunięty: ${widget.filePath}');
    } catch (e) {
      debugPrint('Nie udało się usunąć pliku: $e');
    }
  }

  void _onRecordingComplete() {
    setState(() => _checkFileExists());
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
