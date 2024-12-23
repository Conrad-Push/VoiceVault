import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String closeButtonLabel;
  final VoidCallback? onClosePressed;
  final String? actionButtonLabel;
  final VoidCallback? onActionPressed;
  final Color? actionButtonColor;
  final bool isLoading;
  final bool barrierDismissible;

  const CustomModal({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.iconColor = Colors.blue,
    this.iconSize = 48.0,
    this.closeButtonLabel = 'Zamknij',
    this.onClosePressed,
    this.actionButtonLabel,
    this.onActionPressed,
    this.actionButtonColor = Colors.blue,
    this.isLoading = false,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.32;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: actionButtonLabel != null
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (actionButtonLabel != null)
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: onActionPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isLoading ? Colors.grey[300] : actionButtonColor,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                actionButtonLabel!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                    ),
                  ),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed:
                        onClosePressed ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                    child: Text(closeButtonLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
