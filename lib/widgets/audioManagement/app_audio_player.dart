import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/audio_service.dart';

class AppAudioPlayer extends StatefulWidget {
  final String filePath;
  final VoidCallback onRecordAgain;
  final ValueChanged<Duration?> onDurationChanged;

  const AppAudioPlayer({
    super.key,
    required this.filePath,
    required this.onRecordAgain,
    required this.onDurationChanged,
  });

  @override
  State<AppAudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AppAudioPlayer> {
  final AudioService _audioService = AudioService();
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<dynamic> _playerStateSubscription;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration? _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _totalDuration = await _audioService.initPlayer(widget.filePath);
    widget.onDurationChanged(_totalDuration);

    _positionSubscription = _audioService.positionStream.listen((position) {
      setState(() => _position = position);
    });

    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (duration != null) {
        setState(() => _duration = duration);
      }
    });

    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _position = Duration.zero);
        _audioService.stop();
        _audioService.seek(_position);
      }
    });
  }

  @override
  void dispose() {
    try {
      _positionSubscription.cancel();
      _durationSubscription.cancel();
      _playerStateSubscription.cancel();
    } finally {
      _audioService.dispose();
      super.dispose();
    }
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
                _formatDuration(_position),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
          Slider(
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            value: _position.inSeconds.toDouble(),
            onChangeStart: (value) async {
              await _audioService.pause();
            },
            onChanged: (value) async {
              debugPrint('Time: ${value.toInt()}');
              await _audioService.seek(Duration(seconds: value.toInt()));
            },
            onChangeEnd: (value) async {
              await _audioService.play();
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _audioService.playPause(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _audioService.isPlaying
                        ? Color(0xFFFFA726)
                        : Colors.blue),
                child: Icon(
                  _audioService.isPlaying ? Icons.pause : Icons.play_arrow,
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
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
