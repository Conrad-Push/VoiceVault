import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class RecordingCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? duration;
  final bool isRecorded;
  final VoidCallback? onDelete;
  final VoidCallback? onRecord;
  final VoidCallback? onReRecord;

  const RecordingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.duration,
    required this.isRecorded,
    this.onDelete,
    this.onRecord,
    this.onReRecord,
  });

  @override
  State<RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<RecordingCard> {
  bool _isExpanded = false;
  bool _isFullyExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isFullyExpanded = _isExpanded;
    });
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
                      if (widget.duration != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.duration!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
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
                height: _isExpanded ? 60 : 0,
                child: AnimatedOpacity(
                  opacity: _isFullyExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
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
                                onPressed: widget.onReRecord,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFFFA726), // Pomarańczowy
                                ),
                                child: const Text(
                                  'Nagraj ponownie',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: widget.onRecord,
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
