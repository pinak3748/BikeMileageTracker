import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? messageStyle;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onActionPressed,
    this.iconSize = 80,
    this.iconColor,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: messageStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}