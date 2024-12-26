import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'local_file_service.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final LocalFileService _fileService = LocalFileService.instance;

  Future<void> initRecorder() async {
    await _recorder.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.voiceCommunication,
        flags: AndroidAudioFlags.none,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<String> startRecording(String userId, String fileName) async {
    final filePath = await _fileService.createFilePath(userId, fileName);

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      sampleRate: 44100,
      numChannels: 1,
    );

    return filePath;
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
  }

  Future<void> deleteLocalRecording(String filePath) async {
    await _fileService.deleteFile(filePath);
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
}
