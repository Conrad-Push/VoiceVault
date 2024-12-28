import 'package:flutter/material.dart';

class IndividualPasswordContent extends StatelessWidget {
  final String recordingTitle;

  const IndividualPasswordContent({
    super.key,
    required this.recordingTitle,
  });

  Widget _buildContent() {
    if (recordingTitle == 'Hasło #1' ||
        recordingTitle == 'Hasło #2' ||
        recordingTitle == 'Hasło #3') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Dowolne słowo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '(Składające się z co najmniej 6 liter)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Dla Hasło #4 i Hasło #5
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Dowolna liczba',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          '(Składająca się z 6 cyfr, podawanych przez Ciebie pojedynczo w kolejności, przykładowo: "zero, trzy, dwa, jeden, osiem, siedem")',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
            'Włącz nagrywanie, a następnie wyraźnie wypowiedz wybrane przez siebie hasło, którym będzie:',
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
          child: Center(
            child: _buildContent(),
          ),
        ),
      ],
    );
  }
}
