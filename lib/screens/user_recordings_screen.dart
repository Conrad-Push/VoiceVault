import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_vault/services/firebase/storage_service.dart';
import '../providers/connectivity_provider.dart';
import '../utils/constants.dart';
import '../widgets/interfaceElements/app_header.dart';
import '../widgets/connectionStatus/connection_icon.dart';
import '../widgets/interfaceElements/custom_modal.dart';
import '../widgets/connectionStatus/network_status_banner.dart';
import '../widgets/interfaceElements/screen_title.dart';
import '../widgets/interfaceElements/custom_button.dart';
import '../widgets/cards/recording_card.dart';
import '../providers/user_provider.dart';
import '../services/firebase/firestore_service.dart';
import 'registration_recording_screen.dart';

class UserRecordingsScreen extends StatefulWidget {
  const UserRecordingsScreen({super.key});

  @override
  State<UserRecordingsScreen> createState() => _UserRecordingsScreenState();
}

class _UserRecordingsScreenState extends State<UserRecordingsScreen>
    with WidgetsBindingObserver {
  late Future<Map<String, List<Map<String, dynamic>>>> _recordingsFuture;
  bool _showLoader = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showLoader = false;
        });
      }
    });

    _fetchRecordings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ModalRoute.of(context)?.isCurrent == true) {
      _showLoader = true;

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _showLoader = false;
          });
        }
      });

      _fetchRecordings();
    }
  }

  void _fetchRecordings() {
    final userId = context.read<UserProvider>().userId;

    if (userId != null) {
      setState(() {
        _recordingsFuture = FirestoreService.instance.fetchRecordings(userId);
      });
    } else {
      setState(() {
        _recordingsFuture = Future.value({
          'individualSamples': [],
          'individualPasswords': [],
          'sharedPasswords': [],
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showNoConnectionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Problem z siecią',
          description:
              'Funkcjonalność aplikacji ograniczona z powodu braku dostępu do Internetu.',
          icon: Icons.wifi_off,
          iconColor: Colors.red,
          closeButtonLabel: 'OK',
          onClosePressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _showErrorModal(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Błąd',
          description:
              'Nie udało się wykonać operacji. Szczegóły: $errorMessage',
          icon: Icons.error,
          iconColor: Colors.red,
          closeButtonLabel: 'OK',
          onClosePressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _showDeleteRecordingModal(BuildContext context, String userId,
      String recordingType, String recordingTitle) {
    bool isCheckingConnection = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return CustomModal(
              title: 'Usuń nagranie',
              description:
                  'Czy na pewno chcesz usunąć nagranie "$recordingTitle"?',
              icon: Icons.delete_forever,
              iconColor: Colors.red,
              closeButtonLabel: 'Anuluj',
              onClosePressed: () => Navigator.of(context).pop(),
              actionButtonLabel: 'Usuń',
              actionButtonColor: Colors.red,
              isLoading: isCheckingConnection,
              onActionPressed: () async {
                setModalState(() {
                  isCheckingConnection = true;
                });

                final isConnected =
                    context.read<ConnectivityProvider>().isConnected;

                if (!isConnected) {
                  setModalState(() {
                    isCheckingConnection = false;
                  });

                  _showNoConnectionModal(context);
                  return;
                }

                try {
                  await FirestoreService.instance.deleteRecording(
                    userId: userId,
                    recordingTitle: recordingTitle,
                  );

                  await StorageService.instance.deleteAudioFile(
                    userId: userId,
                    recordingType: recordingType,
                    recordingTitle: recordingTitle,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();

                    _showLoader = true;

                    Future.delayed(const Duration(milliseconds: 1000), () {
                      if (mounted) {
                        setState(() {
                          _showLoader = false;
                        });
                      }
                    });

                    _fetchRecordings();
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showErrorModal(e.toString());
                  }
                } finally {
                  if (context.mounted) {
                    setModalState(() {
                      isCheckingConnection = false;
                    });
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  void _showReRecordModal(BuildContext context, String userId,
      String recordingType, String recordingTitle) {
    bool isCheckingConnection = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return CustomModal(
              title: 'Ponowne nagrywanie',
              description:
                  'Ponowne nagranie spowoduje usunięcie danych z bazy. Czy na pewno chcesz kontynuować?',
              icon: Icons.warning,
              iconColor: const Color(0xFFFFA726),
              closeButtonLabel: 'Anuluj',
              onClosePressed: () => Navigator.of(context).pop(),
              actionButtonLabel: 'Nagraj',
              actionButtonColor: const Color(0xFFFFA726),
              isLoading: isCheckingConnection,
              onActionPressed: () async {
                setModalState(() {
                  isCheckingConnection = true;
                });

                final isConnected =
                    context.read<ConnectivityProvider>().isConnected;

                if (!isConnected) {
                  setModalState(() {
                    isCheckingConnection = false;
                  });

                  _showNoConnectionModal(context);
                  return;
                }

                try {
                  await FirestoreService.instance.deleteRecording(
                    userId: userId,
                    recordingTitle: recordingTitle,
                  );

                  await StorageService.instance.deleteAudioFile(
                    userId: userId,
                    recordingType: recordingType,
                    recordingTitle: recordingTitle,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationRecordingScreen(
                          userId: context.read<UserProvider>().userId!,
                          recordingType: recordingType,
                          recordingTitle: recordingTitle,
                        ),
                      ),
                    ).then((_) {
                      _showLoader = true;

                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted) {
                          setState(() {
                            _showLoader = false;
                          });
                        }
                      });

                      _fetchRecordings();
                    });
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showErrorModal(e.toString());
                  }
                } finally {
                  if (context.mounted) {
                    setModalState(() {
                      isCheckingConnection = false;
                    });
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  List<Widget> _buildSection(
      String title, List<Map<String, dynamic>> recordings,
      {required String recordingType}) {
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
              ? 'Długość nagrania: ${recording['duration']}s'
              : null,
          isRecorded: recording['isRecorded'],
          onDelete: recording['isRecorded']
              ? () => _showDeleteRecordingModal(
                    context,
                    context.read<UserProvider>().userId!,
                    recordingType,
                    recording['title'],
                  )
              : null,
          onRecord: () {
            final isConnected =
                context.read<ConnectivityProvider>().isConnected;
            if (!isConnected) {
              _showNoConnectionModal(context);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrationRecordingScreen(
                  userId: context.read<UserProvider>().userId!,
                  recordingType: recordingType,
                  recordingTitle: recording['title'],
                ),
              ),
            ).then((_) {
              _showLoader = true;

              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  setState(() {
                    _showLoader = false;
                  });
                }
              });

              _fetchRecordings();
            });
          },
          onReRecord: recording['isRecorded']
              ? () => _showReRecordModal(
                    context,
                    context.read<UserProvider>().userId!,
                    recordingType,
                    recording['title'],
                  )
              : null,
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserProvider>().userName;

    return Scaffold(
      appBar: const AppHeader(
        title: 'Voice Vault',
        automaticallyImplyLeading: false,
        trailing: ConnectionIcon(),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const NetworkStatusBanner(),
            ScreenTitle(title: 'Nagrania użytkownika - $userName'),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _recordingsFuture,
                builder: (context, snapshot) {
                  if (_showLoader ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    _showErrorModal(snapshot.error.toString());
                    return const SizedBox();
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
                          'Próbki głosu',
                          recordings['individualSamples']!,
                          recordingType: 'individualSample',
                        ),
                        const SizedBox(height: 16),
                        ..._buildSection(
                          'Hasła indywidualne',
                          recordings['individualPasswords']!,
                          recordingType: 'individualPassword',
                        ),
                        const SizedBox(height: 16),
                        ..._buildSection(
                          'Hasła współdzielone',
                          recordings['sharedPasswords']!,
                          recordingType: 'sharedPassword',
                        ),
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
                onPressed: () => Navigator.pop(context),
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
