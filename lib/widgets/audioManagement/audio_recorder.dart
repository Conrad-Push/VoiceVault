import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

class AudioRecorder extends StatefulWidget {
  final String userId;
  final String recordingType;
  final String recordingTitle;

  const AudioRecorder({
    super.key,
    required this.userId,
    required this.recordingType,
    required this.recordingTitle,
  });

  @override
  State<AudioRecorder> createState() => _RecorderState();
}

class _RecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _audioService.initAudio();
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
      });

      await _audioService.startRecording(
        widget.userId,
        widget.recordingType,
        widget.recordingTitle,
      );
    } catch (e) {
      debugPrint('Error starting recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isRecording)
          Expanded(
            child: Center(
              child: Text(
                'Nagrywanie w toku...',
                style: TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Text(
                'Czekam na nagrywanie...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRecording ? Colors.red : Colors.green,
          ),
          child: Text(_isRecording ? 'Zakończ' : 'Nagraj'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
