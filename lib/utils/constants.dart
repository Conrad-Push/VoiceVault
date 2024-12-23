import 'package:flutter/material.dart';

/// Application colors (used globally across the app)
class AppColors {
  static const Color background = Color(0xFFEFEFEF); // Light gray background
  static const Color primary = Color(0xFF5A7D9A); // Navy blue
  static const Color error = Color.fromARGB(255, 215, 81, 81); // Red
  static const Color disabled = Color(0xFFB0BEC5); // Disabled button color
}

/// Application texts
class AppTexts {
  // Button texts
  static const String loginButton = 'Zaloguj';
  static const String registerButton = 'Zarejestruj';
  static const String cancelButton = 'Anuluj';

  // Home screen
  static const String homeTitle = 'Lista użytkowników';

  // Registration screen
  static const String registrationTitle = 'Rejestracja';
  static const String nameLabel = 'Imię/pseudonim';
  static const String nameHelperText = 'Wpisz swoje imię lub pseudonim';
  static const String emailLabel = 'Adres e-mail';
  static const String emailHelperText = 'Podaj swój e-mail';
  static const String registrationSuccess = 'Rejestracja zakończona sukcesem';
}
