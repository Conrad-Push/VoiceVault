import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';
import '../widgets/screen_title.dart';
import '../widgets/custom_button.dart';
import '../widgets/recording_card.dart';

class UserRecordingsScreen extends StatelessWidget {
  final String userName;

  const UserRecordingsScreen({
    super.key,
    required this.userName,
  });

  List<Widget> _buildSection(
      String title, List<Map<String, dynamic>> recordings) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 8),
      ...recordings.map((recording) {
        return RecordingCard(
          title: recording['title'],
          subtitle:
              recording['isRecorded'] ? recording['subtitle'] : 'Brak nagrania',
          duration: recording['isRecorded'] ? recording['duration'] : null,
          isRecorded: recording['isRecorded'],
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> voiceSamples = [
      {
        'title': 'Próbka #1',
        'subtitle': '2023-12-01',
        'duration': '10s',
        'isRecorded': true
      },
      {
        'title': 'Próbka #2',
        'subtitle': 'Brak daty',
        'duration': '0s',
        'isRecorded': false
      },
      {
        'title': 'Próbka #3',
        'subtitle': '2023-12-02',
        'duration': '15s',
        'isRecorded': true
      },
    ];

    final List<Map<String, dynamic>> individualPasswords = List.generate(
      5,
      (index) => {
        'title': 'Hasło #${index + 1}',
        'subtitle': 'Brak daty',
        'duration': '0s',
        'isRecorded': false,
      },
    );

    final List<Map<String, dynamic>> sharedPasswords = List.generate(
      5,
      (index) => {
        'title': 'Hasło współdzielone #${index + 1}',
        'subtitle': '2023-12-03',
        'duration': '8s',
        'isRecorded': index % 2 == 0, // Tylko co drugie nagranie istnieje
      },
    );

    return Scaffold(
      appBar: AppHeader(
        title: 'Voice Vault',
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ScreenTitle(title: 'Nagrania użytkownika - $userName'),
              const SizedBox(height: 16),
              ..._buildSection('Próbki głosu', voiceSamples),
              const SizedBox(height: 16),
              ..._buildSection('Hasła indywidualne', individualPasswords),
              const SizedBox(height: 16),
              ..._buildSection('Hasła współdzielone', sharedPasswords),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  label: 'Powrót do listy',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
