import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase/firestore_service.dart';
import '../widgets/app_header.dart';
import '../widgets/network_status_banner.dart';
import '../widgets/screen_title.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_modal.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../providers/connectivity_provider.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _emailError;

  void _submitForm() async {
    final isConnected = context.read<ConnectivityProvider>().isConnected;

    if (!isConnected) {
      _showNoConnectionModal();
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Użycie FirestoreService do sprawdzenia emaila
        final emailExists =
            await FirestoreService.instance.isEmailRegistered(_email!);

        if (emailExists) {
          setState(() {
            _emailError = 'Ten adres email jest już zarejestrowany.';
          });
          _formKey.currentState!.validate();
          return;
        }

        // Użycie FirestoreService do dodania użytkownika
        await FirestoreService.instance.addUser(
          name: _name!,
          email: _email!,
        );

        if (context.mounted) {
          _showSuccessModal();
        }
      } catch (e) {
        _showErrorModal();
        debugPrint('Error during registration: $e');
      }
    }
  }

  void _showNoConnectionModal() {
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
          iconSize: 48.0,
          closeButtonLabel: 'Zamknij',
          onClosePressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Rejestracja zakończona',
          description: 'Nowy użytkownik został pomyślnie zarejestrowany.',
          icon: Icons.check_circle,
          iconColor: Colors.green,
          closeButtonLabel: 'Zamknij',
          onClosePressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showErrorModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Błąd',
          description: 'Wystąpił błąd podczas rejestracji użytkownika.',
          icon: Icons.error,
          iconColor: Colors.red,
          closeButtonLabel: 'Zamknij',
          onClosePressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Voice Vault',
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const NetworkStatusBanner(),
              const ScreenTitle(title: AppTexts.registrationTitle),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: AppTexts.nameLabel,
                        helperText: AppTexts.nameHelperText,
                        validator: Validators.validateRequired,
                        onSaved: (value) {
                          _name = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: AppTexts.emailLabel,
                        helperText: AppTexts.emailHelperText,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => Validators.validateEmail(value,
                            dynamicError: _emailError),
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                            _emailError = null;
                          });

                          _formKey.currentState?.validate();
                        },
                        onSaved: (value) {
                          _email = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: AppTexts.registerButton,
                      onPressed: _submitForm,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: AppTexts.cancelButton,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: AppColors.error,
                    ),
                  ],
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
