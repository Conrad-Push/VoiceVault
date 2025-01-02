import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../services/audio_service.dart';

class AppAudioRecorder extends StatefulWidget {
  final String filePath;
  final VoidCallback onRecordingComplete;

  const AppAudioRecorder({
    super.key,
    required this.filePath,
    required this.onRecordingComplete,
  });

  @override
  State<AppAudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AppAudioRecorder> {
  bool _isRecording = false;
  final AudioService _audioService = AudioService();
  late final RecorderController _waveformController;
  int _recordingTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    _waveformController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    await _audioService.initRecorder();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingTime++;
      });

      // Opcjonalnie: Automatyczne zatrzymanie po 60 sekundach
      if (_recordingTime >= 60) {
        _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _recordingTime = 0;
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _recordingTime = 0; // Reset timera przy każdym nagraniu
      });
      _startTimer();
      await _waveformController.record();
      await _audioService.startRecording(widget.filePath);
    } catch (e) {
      debugPrint('Error starting recording: $e');
      setState(() => _isRecording = false);
      _stopTimer();
    }
  }

  Future<void> _stopRecording() async {
    try {
      _stopTimer();
      await _audioService.stopRecording();
      await _waveformController.stop();
      widget.onRecordingComplete();
      debugPrint('Recording stopped. File saved at: ${widget.filePath}');
      setState(() => _isRecording = false);
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _stopTimer();
    }
  }

  String _getRecordingMessage() {
    if (_recordingTime >= 40) {
      return "Możesz zakończyć nagrywanie lub kontynuować";
    }
    return "Czas nagrania: $_recordingTime (s)";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Expanded(
            child: AudioWaveforms(
              enableGesture: false,
              size: Size(MediaQuery.of(context).size.width - 40, 50),
              recorderController: _waveformController,
              waveStyle: const WaveStyle(
                waveColor: Colors.blue,
                extendWaveform: true,
                showMiddleLine: false,
              ),
            ),
          ),
          Text(
            _getRecordingMessage(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording
                  ? const Color(0xFF5A7D9A)
                  : const Color.fromARGB(255, 228, 83, 73),
              foregroundColor: Colors.white,
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
            child: Text(_isRecording ? 'Zakończ' : 'Nagraj'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    _waveformController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
