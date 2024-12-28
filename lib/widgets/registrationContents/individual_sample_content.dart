import 'package:flutter/material.dart';

class IndividualSampleContent extends StatelessWidget {
  final String recordingTitle;

  const IndividualSampleContent({
    super.key,
    required this.recordingTitle,
  });

  String _getReadingText() {
    switch (recordingTitle) {
      case 'Próbka #1':
        return 'To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie. To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.To jest tekst dla próbki pierwszej. Należy go przeczytać płynnie i wyraźnie.';
      case 'Próbka #2':
        return 'To jest tekst dla próbki drugiej. Zachowaj naturalny rytm mowy.';
      case 'Próbka #3':
        return 'To jest tekst dla próbki trzeciej. Prosimy o dokładne przeczytanie.';
      default:
        return 'Nieznany tekst próbki';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Włącz nagrywanie, a następnie wyraźnie przeczytaj tekst podany poniżej:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _getReadingText(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
