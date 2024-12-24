import 'dart:async';
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
  bool _showLoader = true;

  @override
  void initState() {
    super.initState();

    // Dodanie minimalnego czasu wyświetlania loadera
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showLoader = false;
        });
      }
    });

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
          subtitle: recording['isRecorded']
              ? 'Nagrano: ${recording['subtitle']}'
              : 'Brak nagrania',
          duration: recording['isRecorded']
              ? 'Długość nagrania (s): ${recording['duration']}'
              : null,
          isRecorded: recording['isRecorded'],
          onDelete: recording['isRecorded']
              ? () async {
                  try {
                    // Pobierz userId z providera
                    final userId =
                        context.read<UserRecordingsProvider>().userId;

                    if (userId != null) {
                      // Wywołaj funkcję usuwania w FirestoreService
                      await FirestoreService.instance.deleteRecording(
                        userId: userId,
                        title: recording[
                            'title'], // Tytuł nagrania jako klucz dokumentu
                      );

                      // Odśwież dane po usunięciu
                      setState(() {
                        _recordingsFuture =
                            FirestoreService.instance.fetchRecordings(userId);
                      });

                      // Wyświetl komunikat o sukcesie
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nagranie zostało usunięte.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    // Obsługa błędu
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Błąd podczas usuwania nagrania: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              : null,
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
        child: Column(
          children: [
            ScreenTitle(title: 'Nagrania użytkownika - $userName'),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _recordingsFuture,
                builder: (context, snapshot) {
                  if (_showLoader ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Ładowanie nagrań...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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

                  return SingleChildScrollView(
                    child: Column(
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
                    ),
                  );
                },
              ),
            ),
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
    );
  }
}
