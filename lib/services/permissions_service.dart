import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  PermissionsService._privateConstructor();
  static final PermissionsService instance =
      PermissionsService._privateConstructor();

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> requestAllPermissions() async {
    final microphoneStatus = await Permission.microphone.request();

    if (microphoneStatus.isPermanentlyDenied) {
      // Jeśli użytkownik na stałe odmówił pozwolenia, otwórz ustawienia aplikacji
      await openAppSettings();
    }
  }

  Future<bool> checkMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }
}
