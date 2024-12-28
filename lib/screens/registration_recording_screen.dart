import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/network_status_banner.dart';
import '../widgets/screen_title.dart';
import '../widgets/connection_icon.dart';
import '../widgets/custom_modal.dart';
import '../utils/constants.dart';
import '../widgets/registrationContents/individual_sample_content.dart';
import '../widgets/registrationContents/individual_password_content.dart';
import '../widgets/registrationContents/shared_password_content.dart';

class RegistrationRecordingScreen extends StatelessWidget {
  final String userId;
  final String recordingType;
  final String recordingTitle;

  const RegistrationRecordingScreen({
    super.key,
    required this.userId,
    required this.recordingType,
    required this.recordingTitle,
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

  Widget _buildContent() {
    switch (recordingType) {
      case 'individualSample':
        return IndividualSampleContent(recordingTitle: recordingTitle);
      case 'individualPassword':
        return IndividualPasswordContent(recordingTitle: recordingTitle);
      case 'sharedPassword':
        return SharedPasswordContent(recordingTitle: recordingTitle);
      default:
        return const Center(child: Text('Nieznany typ nagrania'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        automaticallyImplyLeading: false,
        title: 'Voice Vault',
        trailing: const ConnectionIcon(),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const NetworkStatusBanner(),
              ScreenTitle(title: 'Nagrywanie - $recordingTitle'),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildContent(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          'Tutaj znajdzie się widget recordera.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showCancelModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Anuluj',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                    ElevatedButton(
                      onPressed: null, // Przycisk na razie nieaktywny
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'Zapisz',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
