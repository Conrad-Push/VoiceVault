import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'local_file_service.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final LocalFileService _fileService = LocalFileService.instance;

  /// Statusy
  bool get isRecording => _recorder.isRecording;
  bool get isInitialized => _recorder.isRecording || _recorder.isStopped;
  bool get isPlaying => _player.isPlaying;

  /// Inicjalizuje recorder i player
  Future<void> initAudio() async {
    try {
      // Inicjalizacja recordera
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

      // Inicjalizacja playera
      await _player.openPlayer();
    } catch (e) {
      debugPrint('Error initializing audio: $e');
      throw Exception('Failed to initialize audio: $e');
    }
  }

  /// Rozpoczyna nagrywanie
  Future<String> startRecording(
      String userId, String recordingType, String recordingTitle) async {
    if (!isInitialized) {
      throw Exception('Recorder is not initialized');
    }

    if (isRecording) {
      throw Exception('Recording is already in progress');
    }

    final filePath = await _fileService.createFilePath(
        userId, recordingType, recordingTitle);

    try {
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
        sampleRate: 44100,
        numChannels: 1,
      );
      return filePath;
    } catch (e) {
      await _fileService.deleteFile(filePath); // Cleanup w razie błędu
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

  /// Pobiera postęp nagrania
  Stream<Duration>? getRecordingProgress() {
    return _recorder.onProgress?.map((e) => e.duration);
  }

  /// Usuwa lokalne nagranie
  Future<void> deleteLocalRecording(String filePath) async {
    try {
      await _fileService.deleteFile(filePath);
    } catch (e) {
      debugPrint('Error deleting local recording: $e');
      throw Exception('Failed to delete local recording: $e');
    }
  }

  /// Odtwarza nagranie
  Future<void> playRecording(String filePath) async {
    if (_player.isPlaying) {
      throw Exception('Audio is already playing');
    }

    try {
      await _player.startPlayer(fromURI: filePath, codec: Codec.pcm16WAV);
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
