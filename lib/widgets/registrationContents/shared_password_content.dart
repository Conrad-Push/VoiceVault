import 'package:flutter/material.dart';

class SharedPasswordContent extends StatelessWidget {
  final String recordingTitle;

  const SharedPasswordContent({
    super.key,
    required this.recordingTitle,
  });

  Widget _buildContent() {
    switch (recordingTitle) {
      case 'Hasło współdzielone #1':
        return const Text(
          'AUTORYZACJA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        );

      case 'Hasło współdzielone #2':
        return const Text(
          'SZYFROWANIE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        );

      case 'Hasło współdzielone #3':
        return const Text(
          'BEZPIECZEŃSTWO',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        );

      case 'Hasło współdzielone #4':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '123456',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '(Podaj cyfry pojedynczo i w kolejności, np.: "jeden, dwa, trzy, cztery, pięć, sześć")',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 'Hasło współdzielone #5':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '654321',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '(Podaj cyfry pojedynczo i w kolejności, np.: "sześć, pięć, cztery, trzy, dwa, jeden")',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      default:
        return const Text('Nieznane hasło współdzielone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Włącz nagrywanie, a następnie wyraźnie wypowiedz poniżej zdefiniowane hasło:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),
      ],
    );
  }
}
