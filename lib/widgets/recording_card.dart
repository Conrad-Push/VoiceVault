import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RecordingCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? duration; // Czas może być null
  final bool isRecorded;
  final VoidCallback? onDelete;

  const RecordingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.duration,
    required this.isRecorded,
    this.onDelete,
  });

  @override
  State<RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<RecordingCard> {
  bool _isExpanded = false;
  bool _isFullyExpanded = false;

  void _toggleExpansion() {
    if (_isExpanded) {
      // Przy zwijaniu najpierw zmniejszamy opacity
      setState(() {
        _isFullyExpanded = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isExpanded = false;
          });
        }
      });
    } else {
      // Przy rozwijaniu najpierw zwiększamy wysokość
      setState(() {
        _isExpanded = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isFullyExpanded = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (widget.duration != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.duration!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 10,
                  backgroundColor:
                      widget.isRecorded ? Colors.green : Colors.red,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                height:
                    _isExpanded ? 60 : 0, // Stała wysokość rozwiniętej sekcji
                child: AnimatedOpacity(
                  opacity: _isFullyExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: Center(
                    child: widget.isRecorded
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: widget.onDelete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Usuń',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  debugPrint('Re-recording sample');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFFFFA726), // Kolor pomarańczowy
                                ),
                                child: const Text(
                                  'Nagraj ponownie',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () {
                              debugPrint('Start recording');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text(
                              'Nagraj',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
