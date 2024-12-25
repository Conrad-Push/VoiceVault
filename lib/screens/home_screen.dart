import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/users_list.dart';
import '../widgets/custom_button.dart';
import '../widgets/screen_title.dart';
import '../widgets/network_status_banner.dart';
import '../widgets/custom_modal.dart';
import 'user_registration_screen.dart';
import '../utils/constants.dart';
import '../services/firebase/firestore_service.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/connection_icon.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().clearData();
    });

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
    if (state == AppLifecycleState.resumed &&
        ModalRoute.of(context)?.isCurrent == true) {
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
          closeButtonLabel: 'Zamknij',
          onClosePressed: () => Navigator.of(context).pop(),
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
                    onReturn: _fetchUsers, // Callback wywoływany po powrocie
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
