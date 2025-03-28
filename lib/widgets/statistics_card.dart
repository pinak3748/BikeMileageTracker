import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final double elevation;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.onTap,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? AppColors.cardBackground,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? AppColors.text,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor?.withOpacity(0.8) ?? AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}