import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import '../../services/local_file_service.dart';

class AudioPlayer extends StatefulWidget {
  final String filePath;
  final VoidCallback? onFileDeleted;

  const AudioPlayer({
    super.key,
    required this.filePath,
    this.onFileDeleted,
  });

  @override
  State<AudioPlayer> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayer> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isPlayerReady = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _playerSubscription;
  final _sliderPositionNotifier = ValueNotifier<Duration>(Duration.zero);

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _player.openPlayer();
    setState(() => _isPlayerReady = true);

    // Set up player subscription to track position
    _playerSubscription = _player.onProgress?.listen((e) {
      final duration = e.duration;
      final position = e.position;

      setState(() {
        _duration = duration;
        _position = position;
      });
      _sliderPositionNotifier.value = position;
    });
  }

  Future<void> _playPause() async {
    if (!_isPlayerReady) return;

    if (_player.isStopped) {
      await _player.startPlayer(
        fromURI: widget.filePath,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          setState(() => _isPlaying = false);
          _sliderPositionNotifier.value = Duration.zero;
        },
      );
      setState(() => _isPlaying = true);
    } else if (_player.isPlaying) {
      await _player.pausePlayer();
      setState(() => _isPlaying = false);
    } else if (_player.isPaused) {
      await _player.resumePlayer();
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _stopPlaying() async {
    if (!_isPlayerReady) return;

    await _player.stopPlayer();
    setState(() => _isPlaying = false);
    _sliderPositionNotifier.value = Duration.zero;
  }

  Future<void> _seekTo(Duration position) async {
    if (!_isPlayerReady) return;

    await _player.seekToPlayer(position);
  }

  Future<void> _deleteFile() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text(
            'Are you sure you want to delete this recording? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      // Stop playback if playing
      if (_player.isPlaying || _player.isPaused) {
        await _stopPlaying();
      }

      // Delete the file
      await LocalFileService.instance.deleteFile(widget.filePath);

      // Notify parent widget
      widget.onFileDeleted?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _player.closePlayer();
    _sliderPositionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time and Slider
          Row(
            children: [
              Text(_formatDuration(_position)),
              Expanded(
                child: ValueListenableBuilder<Duration>(
                  valueListenable: _sliderPositionNotifier,
                  builder: (context, position, _) {
                    return Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: _duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _sliderPositionNotifier.value =
                            Duration(milliseconds: value.toInt());
                      },
                      onChangeEnd: (value) {
                        _seekTo(Duration(milliseconds: value.toInt()));
                      },
                    );
                  },
                ),
              ),
              Text(_formatDuration(_duration)),
            ],
          ),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: _playPause,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: _stopPlaying,
                icon: const Icon(Icons.stop),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: _deleteFile,
                icon: const Icon(Icons.delete),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
