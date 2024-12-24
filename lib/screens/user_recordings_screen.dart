import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';
import '../widgets/screen_title.dart';
import '../widgets/custom_button.dart';
import '../widgets/recording_card.dart';
import '../providers/user_recordings_provider.dart';
import '../services/firebase/firestore_service.dart';

class UserRecordingsScreen extends StatefulWidget {
  const UserRecordingsScreen({super.key});

  @override
  State<UserRecordingsScreen> createState() => _UserRecordingsScreenState();
}

class _UserRecordingsScreenState extends State<UserRecordingsScreen> {
  late Future<Map<String, List<Map<String, dynamic>>>> _recordingsFuture;

  @override
  void initState() {
    super.initState();

    // Pobieranie userId z providera i fetchowanie nagrań
    final userId = context.read<UserRecordingsProvider>().userId;
    if (userId != null) {
      _recordingsFuture = FirestoreService.instance.fetchRecordings(userId);
    } else {
      _recordingsFuture = Future.value({
        'individualSamples': [],
        'individualPasswords': [],
        'sharedPasswords': [],
      });
    }
  }

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
    final userName = context.watch<UserRecordingsProvider>().userName;

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
              FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _recordingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Błąd podczas pobierania nagrań',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final recordings = snapshot.data ??
                      {
                        'individualSamples': [],
                        'individualPasswords': [],
                        'sharedPasswords': [],
                      };

                  return Column(
                    children: [
                      ..._buildSection(
                          'Próbki głosu', recordings['individualSamples']!),
                      const SizedBox(height: 16),
                      ..._buildSection('Hasła indywidualne',
                          recordings['individualPasswords']!),
                      const SizedBox(height: 16),
                      ..._buildSection('Hasła współdzielone',
                          recordings['sharedPasswords']!),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  label: 'Powrót do listy',
                  onPressed: () {
                    // Czyszczenie providera i powrót
                    context.read<UserRecordingsProvider>().clearData();
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
