import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permissions_service.dart';
import '../widgets/interfaceElements/app_header.dart';
import '../widgets/lists/users_list.dart';
import '../widgets/interfaceElements/custom_button.dart';
import '../widgets/interfaceElements/screen_title.dart';
import '../widgets/connectionStatus/network_status_banner.dart';
import '../widgets/interfaceElements/custom_modal.dart';
import 'user_registration_screen.dart';
import '../utils/constants.dart';
import '../services/firebase/firestore_service.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/connectionStatus/connection_icon.dart';

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
    _requestPermissions();
    _fetchUsers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().clearData();
    });

    context.read<ConnectivityProvider>().addListener(() {
      if (mounted && context.read<ConnectivityProvider>().isConnected) {
        _fetchUsers();
      }
    });
  }

  Future<void> _requestPermissions() async {
    try {
      final microphoneStatus = await Permission.microphone.status;

      if (microphoneStatus.isGranted) {
        return;
      }

      if (microphoneStatus.isDenied) {
        final newStatus =
            await PermissionsService.instance.requestMicrophonePermission();

        if (!newStatus) {
          _showPermissionDeniedModal();
        }
        return;
      }

      if (microphoneStatus.isPermanentlyDenied) {
        _showPermissionDeniedModal();
      }
    } catch (e) {
      debugPrint("Error requesting microphone permission: $e");
    }
  }

  void _showPermissionDeniedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Dostęp do mikrofonu',
          description:
              'Aby aplikacja działała poprawnie, wymagany jest dostęp do mikrofonu. Możesz nadać dostęp w ustawieniach aplikacji.',
          icon: Icons.mic_off,
          iconColor: Colors.red,
          closeButtonLabel: 'Anuluj',
          onClosePressed: () => Navigator.of(context).pop(),
          actionButtonLabel: 'Ustawienia',
          actionButtonColor: Colors.blue,
          onActionPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ModalRoute.of(context)?.isCurrent == true) {
      _requestPermissions();
      _fetchUsers();
      _clearUserRecordingsProvider();
    }
  }

  void _fetchUsers() {
    setState(() {
      _usersFuture = FirestoreService.instance.fetchUsers();
    });
  }

  void _clearUserRecordingsProvider() {
    context.read<UserProvider>().clearData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Voice Vault',
        trailing: ConnectionIcon(),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                    onReturn: _fetchUsers,
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
                        _showNoConnectionModal(context);
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
