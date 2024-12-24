import 'package:flutter/material.dart';

class RecordingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? duration; // Czas może być null
  final bool isRecorded;
  final VoidCallback? onDelete; // Callback do obsługi usuwania

  const RecordingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.duration,
    required this.isRecorded,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (duration != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    duration!,
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
            backgroundColor: isRecorded ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          if (isRecorded)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
