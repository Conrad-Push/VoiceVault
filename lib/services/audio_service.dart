import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  /// Statusy
  bool get isRecording => _recorder.isRecording;
  bool get isInitialized => _recorder.isRecording || _recorder.isStopped;
  bool get isPlaying => _player.isPlaying;

  /// Inicjalizuje tylko recorder
  Future<void> initRecorder() async {
    try {
      await _recorder.openRecorder();
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.measurement,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.media,
          flags: AndroidAudioFlags.none,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      debugPrint('Recorder initialized');
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
      throw Exception('Failed to initialize recorder: $e');
    }
  }

  /// Inicjalizuje tylko player
  Future<void> initPlayer() async {
    try {
      await _player.openPlayer();
      debugPrint('Player initialized');
    } catch (e) {
      debugPrint('Error initializing player: $e');
      throw Exception('Failed to initialize player: $e');
    }
  }

  /// Rozpoczyna nagrywanie
  Future<void> startRecording(String filePath) async {
    if (!isInitialized) {
      throw Exception('Recorder is not initialized');
    }
    if (isRecording) {
      throw Exception('Recording is already in progress');
    }
    try {
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
        sampleRate: 44100,
        numChannels: 1,
      );
      debugPrint('Recording started. Saving to: $filePath');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Zatrzymuje nagrywanie
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Odtwarza nagranie
  Future<void> playRecording(String filePath,
      {VoidCallback? whenFinished}) async {
    if (_player.isPlaying) {
      throw Exception('Audio is already playing');
    }

    try {
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
        whenFinished: whenFinished,
      );
    } catch (e) {
      debugPrint('Error playing recording: $e');
      throw Exception('Failed to play recording: $e');
    }
  }

  /// Zatrzymuje odtwarzanie
  Future<void> stopPlayback() async {
    try {
      if (_player.isPlaying) {
        await _player.stopPlayer();
      }
    } catch (e) {
      debugPrint('Error stopping playback: $e');
    }
  }

  /// Ustawia pozycję odtwarzania
  Future<void> seekToPosition(Duration position) async {
    try {
      await _player.seekToPlayer(position);
      debugPrint('Seeked to position: ${position.inSeconds} seconds');
    } catch (e) {
      debugPrint('Error seeking to position: $e');
    }
  }

  /// Zwalnia zasoby recorder i player
  Future<void> dispose() async {
    try {
      if (isRecording) {
        await stopRecording();
      }
      if (isPlaying) {
        await stopPlayback();
      }
      await _recorder.closeRecorder();
      await _player.closePlayer();
    } catch (e) {
      debugPrint('Error disposing audio service: $e');
    }
  }
}
