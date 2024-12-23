class Validators {
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'To pole nie może być puste';
    }
    return null;
  }

  static String? validateEmail(String? value, {String? dynamicError}) {
    if (value == null || value.isEmpty) {
      return 'To pole nie może być puste';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Podaj poprawny adres e-mail';
    } else if (dynamicError != null) {
      return dynamicError;
    }
    return null;
  }
}
