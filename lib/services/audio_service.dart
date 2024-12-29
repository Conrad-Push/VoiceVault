import 'package:flutter_sound/flutter_sound.dart' as f_s;
import 'package:just_audio/just_audio.dart' as j_a;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final f_s.FlutterSoundRecorder _recorder = f_s.FlutterSoundRecorder();
  final j_a.AudioPlayer _player = j_a.AudioPlayer();

  /// Statusy
  bool get isRecording => _recorder.isRecording;
  bool get isPlaying => _player.playing;

  /// Strumienie
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<j_a.PlayerState> get playerStateStream => _player.playerStateStream;

  /// Inicjalizuje recorder
  Future<void> initRecorder() async {
    try {
      await _recorder.openRecorder();
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.defaultToSpeaker,
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
      throw Exception('Failed to initialize recorder');
    }
  }

  /// Rozpoczyna nagrywanie
  Future<void> startRecording(String filePath) async {
    try {
      await _recorder.startRecorder(
        toFile: filePath,
        codec: f_s.Codec.pcm16WAV,
        sampleRate: 44100,
        numChannels: 1,
      );
      debugPrint('Recording started. Saving to: $filePath');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      throw Exception('Failed to start recording');
    }
  }

  /// Zatrzymuje nagrywanie
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      debugPrint('Recording stopped. Saved to: $path');
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Inicjalizuje player
  Future<Duration?> initPlayer(String filePath) async {
    try {
      final duration = await _player.setFilePath(filePath);
      debugPrint('Player initialized with file: $filePath');
      return duration;
    } catch (e) {
      debugPrint('Error initializing player: $e');
      throw Exception('Failed to initialize player');
    }
  }

  /// Odtwarza lub pauzuje nagranie
  Future<void> playPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
        debugPrint('Playback paused');
      } else {
        await _player.play();
        debugPrint('Playback paused');
      }
    } catch (e) {
      debugPrint('Error during play/pause: $e');
      throw Exception('Failed to play or pause');
    }
  }

  /// Odtwarza nagranie
  Future<void> play() async {
    try {
      if (!_player.playing) {
        await _player.play();
        debugPrint('Playback started');
      }
    } catch (e) {
      debugPrint('Error during play: $e');
      throw Exception('Failed to pause');
    }
  }

  /// Pauzuje nagranie
  Future<void> pause() async {
    try {
      if (_player.playing) {
        await _player.pause();
        debugPrint('Playback paused');
      }
    } catch (e) {
      debugPrint('Error during pause: $e');
      throw Exception('Failed to pause');
    }
  }

  /// Stopuje odtwarzacz
  Future<void> stop() async {
    try {
      await _player.stop();
      debugPrint('Player stopped');
    } catch (e) {
      debugPrint('Error stopping player: $e');
    }
  }

  /// Przewija do pozycji
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      debugPrint('Seeked to position: $position');
    } catch (e) {
      debugPrint('Error seeking to position: $e');
      throw Exception('Failed to seek position');
    }
  }

  /// Zwalnia zasoby recorder i player
  Future<void> dispose() async {
    try {
      if (isRecording) {
        await stopRecording();
      }
      if (isPlaying) {
        await stop();
      }
      await _recorder.closeRecorder();
      await _player.dispose();
      debugPrint('Resources disposed');
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }
  }
}
