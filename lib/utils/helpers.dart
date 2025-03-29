import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Format currency based on locale
String formatCurrency(double amount, {String locale = 'en_US', String? symbol}) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: symbol ?? '\$',
  );
  return formatter.format(amount);
}

// Format date to display
String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
  return DateFormat(format).format(date);
}

// Format distance with units (km or miles)
String formatDistance(double distance, {bool useMetric = true}) {
  if (useMetric) {
    return '${distance.toStringAsFixed(1)} km';
  } else {
    // Convert to miles
    final miles = distance * 0.621371;
    return '${miles.toStringAsFixed(1)} mi';
  }
}

// Format volume with units (liters or gallons)
String formatVolume(double volume, {bool useMetric = true}) {
  if (useMetric) {
    return '${volume.toStringAsFixed(2)} L';
  } else {
    // Convert to gallons
    final gallons = volume * 0.264172;
    return '${gallons.toStringAsFixed(2)} gal';
  }
}

// Calculate fuel economy (km/L or mpg)
double calculateFuelEconomy(
    double distance, double volume, {bool useMetric = true}) {
  if (volume == 0) return 0;
  
  if (useMetric) {
    // km/L
    return distance / volume;
  } else {
    // MPG (miles per gallon)
    final miles = distance * 0.621371;
    final gallons = volume * 0.264172;
    return miles / gallons;
  }
}

// Format fuel economy value with units
String formatFuelEconomy(double economy, {bool useMetric = true}) {
  if (useMetric) {
    return '${economy.toStringAsFixed(2)} km/L';
  } else {
    return '${economy.toStringAsFixed(2)} mpg';
  }
}

// Calculate time difference in a human-readable format
String getTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} years ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}

// Calculate time until a future date in a human-readable format
String getTimeUntil(DateTime futureDate) {
  final now = DateTime.now();
  if (futureDate.isBefore(now)) {
    return 'Overdue';
  }
  
  final difference = futureDate.difference(now);

  if (difference.inDays > 365) {
    return 'In ${(difference.inDays / 365).floor()} years';
  } else if (difference.inDays > 30) {
    return 'In ${(difference.inDays / 30).floor()} months';
  } else if (difference.inDays > 0) {
    return 'In ${difference.inDays} days';
  } else if (difference.inHours > 0) {
    return 'In ${difference.inHours} hours';
  } else if (difference.inMinutes > 0) {
    return 'In ${difference.inMinutes} minutes';
  } else {
    return 'Now';
  }
}

// Show a simple confirmation dialog
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
  
  return result ?? false;
}