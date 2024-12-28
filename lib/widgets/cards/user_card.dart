import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserCard extends StatefulWidget {
  final String name;
  final String email;
  final String recordings;
  final VoidCallback? onTap; // Dodano obsługę onTap
  final VoidCallback? onLongPress;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    required this.recordings,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isPressed = false;

  void _resetPressedState() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Obsługa onTap
      onLongPressStart: (_) {
        setState(() {
          _isPressed = true;
        });

        HapticFeedback.vibrate();

        _resetPressedState();

        if (widget.onLongPress != null) {
          widget.onLongPress!();
        }
      },
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        _resetPressedState();
      },
      onTapCancel: _resetPressedState,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nagrania: ${widget.recordings}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.person,
              size: 32,
              color: Colors.black54,
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
