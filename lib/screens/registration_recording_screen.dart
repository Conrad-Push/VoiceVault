import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/network_status_banner.dart';
import '../widgets/screen_title.dart';
import '../widgets/connection_icon.dart';
import '../widgets/custom_modal.dart';
import '../utils/constants.dart';

class RegistrationRecordingScreen extends StatelessWidget {
  final String userId;
  final String recordingType;
  final String fileName;

  const RegistrationRecordingScreen({
    super.key,
    required this.userId,
    required this.recordingType,
    required this.fileName,
  });

  void _showCancelModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Przerwanie nagrywania',
          description:
              'Jeśli opuścisz ekran, cały postęp zostanie utracony. Czy na pewno chcesz kontynuować?',
          icon: Icons.warning,
          iconColor: Colors.orange,
          closeButtonLabel: 'Nie',
          onClosePressed: () => Navigator.of(context).pop(),
          actionButtonLabel: 'Tak',
          actionButtonColor: Colors.red,
          onActionPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Voice Vault',
        trailing: const ConnectionIcon(),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NetworkStatusBanner(),
            const ScreenTitle(title: 'Nagrywanie'),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'UserID: $userId\nRecording Type: $recordingType\nFile Name: $fileName',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ElevatedButton(
                onPressed: () => _showCancelModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Anuluj',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
