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
          children: [
            const NetworkStatusBanner(),
            ScreenTitle(title: 'Nagrywanie - $recordingTitle'),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Włącz nagrywanie i przeczytaj podany tekst poniżej:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: const Text(
                              'To jest przykładowy tekst, który należy przeczytać podczas nagrywania. Można go zastąpić dowolną treścią, która będzie odpowiadała wymaganiom danego procesu nagrywania.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Miejsce na kolejne elementy
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
