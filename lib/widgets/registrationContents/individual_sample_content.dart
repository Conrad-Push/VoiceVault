import 'package:flutter/material.dart';
import 'package:voice_vault/utils/constants.dart';

class IndividualSampleContent extends StatelessWidget {
  final String recordingTitle;

  const IndividualSampleContent({
    super.key,
    required this.recordingTitle,
  });

  String _getReadingText() {
    switch (recordingTitle) {
      case 'Próbka #1':
        return AppTexts.individualSample1Text;
      case 'Próbka #2':
        return AppTexts.individualSample2Text;
      case 'Próbka #3':
        return AppTexts.individualSample3Text;
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
        Expanded(
          child: Padding(
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
                      fontSize: 16,
                      color: Colors.black87,
                    ),
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
