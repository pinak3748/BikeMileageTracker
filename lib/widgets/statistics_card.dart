import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? AppColors.primary,
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor ??
                          (backgroundColor == null
                              ? Colors.white
                              : Colors.grey[700]),
                    ),
                  ),
                  Icon(
                    icon,
                    color: iconColor ??
                        (backgroundColor == null
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.primary),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor ??
                      (backgroundColor == null
                          ? Colors.white
                          : Colors.grey[900]),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor != null
                        ? textColor!.withOpacity(0.7)
                        : (backgroundColor == null
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey[600]),
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