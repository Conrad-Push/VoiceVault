import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

class AudioPlayer extends StatefulWidget {
  final String filePath;
  final VoidCallback onRecordAgain;

  const AudioPlayer({
    super.key,
    required this.filePath,
    required this.onRecordAgain,
  });

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  final Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _audioService.initPlayer();
    setState(() {
      _totalDuration =
          Duration.zero; // Możemy zainicjować na 0, jeśli brak danych
    });
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioService.stopPlayback();
    } else {
      await _audioService.playRecording(
        widget.filePath,
        whenFinished: () => setState(() => _isPlaying = false),
      );
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
          Slider(
            value: _currentPosition.inSeconds.toDouble(),
            max: _totalDuration.inSeconds.toDouble() > 0
                ? _totalDuration.inSeconds.toDouble()
                : 1.0,
            onChanged: (value) async {
              final newPosition = Duration(seconds: value.toInt());
              await _audioService.seekToPosition(newPosition);
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _playPause,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: widget.onRecordAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 228, 83, 73),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Nagraj ponownie'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
