import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../services/audio_service.dart';

class AudioRecorder extends StatefulWidget {
  final String filePath;
  final VoidCallback onRecordingComplete;

  const AudioRecorder({
    super.key,
    required this.filePath,
    required this.onRecordingComplete,
  });

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  final AudioService _audioService = AudioService();
  late final RecorderController _waveformController;

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

  Future<void> _startRecording() async {
    try {
      setState(() => _isRecording = true);
      await _waveformController.record();
      await _audioService.startRecording(widget.filePath);
    } catch (e) {
      debugPrint('Error starting recording: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioService.stopRecording();
      await _waveformController.stop();
      widget.onRecordingComplete();
      debugPrint('Recording stopped. File saved at: ${widget.filePath}');
      setState(() => _isRecording = false);
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
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
    super.dispose();
  }
}
