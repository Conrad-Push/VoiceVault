import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_header.dart';
import '../widgets/users_list.dart';
import '../widgets/custom_button.dart';
import '../widgets/screen_title.dart';
import '../widgets/network_status_banner.dart';
import '../widgets/custom_modal.dart';
import 'user_registration_screen.dart';
import '../utils/constants.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../providers/connectivity_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUsers();

    context.read<ConnectivityProvider>().addListener(() {
      if (mounted && context.read<ConnectivityProvider>().isConnected) {
        _fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUsers();
    }
  }

  void _fetchUsers() {
    setState(() {
      _usersFuture = FirebaseService.instance.fetchUsers(context);
    });
  }

  void _showNoConnectionModal() {
    bool isCheckingConnection = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return CustomModal(
              title: 'Problem z siecią',
              description:
                  'Funkcjonalność aplikacji ograniczona z powodu braku dostępu do Internetu.',
              icon: Icons.wifi_off,
              iconColor: Colors.red,
              iconSize: 48.0,
              closeButtonLabel: 'Zamknij',
              onClosePressed: () {
                if (!isCheckingConnection) {
                  Navigator.of(context).pop();
                }
              },
              actionButtonLabel: 'Odśwież',
              isLoading: isCheckingConnection,
              onActionPressed: () async {
                setModalState(() {
                  isCheckingConnection = true;
                });

                await Future.delayed(const Duration(seconds: 1));

                if (context.mounted) {
                  final isConnected =
                      context.read<ConnectivityProvider>().isConnected;

                  setModalState(() {
                    isCheckingConnection = false;
                  });

                  if (isConnected) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserRegistrationScreen(),
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Voice Vault'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Dodano SafeArea
        child: Column(
          children: [
            const NetworkStatusBanner(),
            const ScreenTitle(title: AppTexts.homeTitle),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return UsersList(
                      errorMessage: 'Error: ${snapshot.error}',
                      onUserDeleted: _fetchUsers,
                    );
                  }
                  return UsersList(
                    users: snapshot.data,
                    onUserDeleted: _fetchUsers,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  CustomButton(
                    label: AppTexts.loginButton,
                    onPressed: null,
                    color: AppColors.disabled,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: AppTexts.registerButton,
                    onPressed: () {
                      final isConnected =
                          context.read<ConnectivityProvider>().isConnected;
                      if (!isConnected) {
                        _showNoConnectionModal();
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserRegistrationScreen(),
                        ),
                      ).then((_) {
                        _fetchUsers();
                      });
                    },
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
