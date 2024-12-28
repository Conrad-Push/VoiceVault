import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'local_file_service.dart';
import 'package:flutter/foundation.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final LocalFileService _fileService = LocalFileService.instance;

  /// Sprawdza czy recorder jest aktualnie w trakcie nagrywania
  bool get isRecording => _recorder.isRecording;

  /// Sprawdza czy recorder został poprawnie zainicjalizowany
  bool get isInitialized => _recorder.isRecording || _recorder.isStopped;

  /// Inicjalizuje recorder i konfiguruje sesję audio
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
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
      throw Exception('Failed to initialize recorder: $e');
    }
  }

  /// Rozpoczyna nagrywanie
  Future<String> startRecording(String userId, String fileName) async {
    if (!isInitialized) {
      throw Exception('Recorder is not initialized');
    }

    if (isRecording) {
      throw Exception('Recording is already in progress');
    }

    final filePath = await _fileService.createFilePath(userId, fileName);

    try {
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
        sampleRate: 44100,
        numChannels: 1,
      );
      return filePath;
    } catch (e) {
      await _fileService.deleteFile(filePath); // cleanup w razie błędu
      debugPrint('Error starting recording: $e');
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Zatrzymuje aktualne nagrywanie
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Pobiera aktualną długość nagrania w milisekundach
  Stream<Duration>? getRecordingProgress() {
    return _recorder.onProgress?.map((e) => e.duration);
  }

  /// Usuwa lokalny plik nagrania
  Future<void> deleteLocalRecording(String filePath) async {
    try {
      await _fileService.deleteFile(filePath);
    } catch (e) {
      debugPrint('Error deleting local recording: $e');
      throw Exception('Failed to delete local recording: $e');
    }
  }

  /// Zwalnia zasoby recordera
  Future<void> dispose() async {
    try {
      if (isRecording) {
        await stopRecording();
      }
      await _recorder.closeRecorder();
    } catch (e) {
      debugPrint('Error disposing recorder: $e');
    }
  }
}
