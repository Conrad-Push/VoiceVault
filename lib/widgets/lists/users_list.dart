import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firebase/firestore_service.dart';
import '../cards/user_card.dart';
import '../interfaceElements/custom_modal.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/user_recordings_screen.dart';

class UsersList extends StatelessWidget {
  final List<UserModel>? users;
  final String? errorMessage;
  final VoidCallback onUserDeleted;
  final VoidCallback? onReturn; // Nowy callback

  const UsersList({
    super.key,
    this.users,
    this.errorMessage,
    required this.onUserDeleted,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (users == null || users!.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: users!.length,
      itemBuilder: (context, index) {
        final user = users![index];

        // Obliczamy sumę wszystkich nagrań użytkownika
        final totalRecordings = user.individualSamples +
            user.individualPasswords +
            user.sharedPasswords;

        return UserCard(
          name: user.displayName,
          email: user.email,
          recordings: '$totalRecordings/13',
          onTap: () {
            final isConnected =
                context.read<ConnectivityProvider>().isConnected;

            if (!isConnected) {
              // Wyświetl modal o braku połączenia
              _showNoConnectionModal(context);
              return;
            }

            // Ustawiamy użytkownika w providerze
            context.read<UserProvider>().setUser(
                  userId: user.id,
                  userName: user.displayName,
                );

            // Przechodzimy na ekran nagrań
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserRecordingsScreen(),
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<UserProvider>().clearData();
                if (onReturn != null) {
                  onReturn!();
                }
              }
            });
          },
          onLongPress: () {
            _showDeleteUserModal(context, user.id, user.displayName);
          },
        );
      },
    );
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

  void _showDeleteUserModal(
      BuildContext context, String userId, String userName) {
    bool isCheckingConnection = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return CustomModal(
              title: 'Usuń użytkownika',
              description:
                  'Czy na pewno chcesz usunąć użytkownika "$userName"?',
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

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomModal(
                        title: 'Brak połączenia',
                        description:
                            'Nie można usunąć użytkownika bez dostępu do Internetu.',
                        icon: Icons.wifi_off,
                        iconColor: Colors.red,
                        closeButtonLabel: 'OK',
                        onClosePressed: () => Navigator.of(context).pop(),
                      );
                    },
                  );
                  return;
                }

                try {
                  await FirestoreService.instance.deleteUser(userId);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onUserDeleted();
                  }
                } catch (e) {
                  debugPrint('Error during user deletion: $e');
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
}
