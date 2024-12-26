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

  String _getInstruction(String recordingType, String recordingTitle) {
    switch (recordingType) {
      case 'individualSample':
        return 'Włącz nagrywanie, a następnie wyraźnie przeczytaj tekst podany poniżej:';
      case 'individualPassword':
        return 'Włącz nagrywanie, a następnie wyraźnie wypowiedz wybrane przez siebie hasło, którym będzie:';
      case 'sharedPassword':
        return 'Włącz nagrywanie, a następnie wyraźnie wypowiedz poniżej zdefiniowane hasło:';
      default:
        return 'Nieznany typ nagrania. Skontaktuj się z administratorem.';
    }
  }

  String? _getReadingText(String recordingType, String recordingTitle) {
    if (recordingType == 'individualSample') {
      switch (recordingTitle) {
        case 'Próbka #1':
          return 'To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.';
        case 'Próbka #2':
          return 'To jest tekst dla próbki drugiej. Zachowaj naturalny rytm mowy.';
        case 'Próbka #3':
          return 'To jest tekst dla próbki trzeciej. Prosimy o dokładne przeczytanie.';
        default:
          return null;
      }
    }
    return null;
  }

  Widget? _getPasswordContent(String recordingTitle) {
    if (recordingTitle == 'Hasło #1' ||
        recordingTitle == 'Hasło #2' ||
        recordingTitle == 'Hasło #3') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Dowolne słowo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '(Składające się z co najmniej 6 liter)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (recordingTitle == 'Hasło #4' || recordingTitle == 'Hasło #5') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Dowolna liczba',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '(Składająca się z 6 cyfr, podawanych przez Ciebie pojedynczo w kolejności, przykładowo: "zero, trzy, dwa, jeden, osiem, siedem")',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return null;
  }

  List<String> _getSharedPasswordContent() {
    return [
      'Hasło 1: "bezpieczeństwo"',
      'Hasło 2: "szyfrowanie"',
      'Hasło 3: "autoryzacja"',
      'Liczba główna: 123456',
      'Liczba pomocnicza: 654321'
    ];
  }

  @override
  Widget build(BuildContext context) {
    final instruction = _getInstruction(recordingType, recordingTitle);
    final readingText = _getReadingText(recordingType, recordingTitle);
    final sharedPasswords =
        recordingType == 'sharedPassword' ? _getSharedPasswordContent() : null;
    final passwordContent = recordingType == 'individualPassword'
        ? _getPasswordContent(recordingTitle)
        : null;

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (readingText != null)
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
                              child: Text(
                                readingText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (passwordContent != null)
                    Expanded(
                      child: Center(
                        child: passwordContent,
                      ),
                    ),
                  if (sharedPasswords != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sharedPasswords.map((password) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                password,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
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
