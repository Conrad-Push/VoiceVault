import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? helperText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged; // Dodano obsługę onChanged

  const CustomTextField({
    super.key,
    required this.label,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSaved,
    this.onChanged, // Dodano obsługę onChanged
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged, // Przekazanie obsługi onChanged
    );
  }
}
