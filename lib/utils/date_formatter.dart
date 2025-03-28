import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');
  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final _numberFormat = NumberFormat('#,##0.00');
  static final _percentFormat = NumberFormat.percentPattern();
  static final _distanceFormat = NumberFormat('#,##0');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }

  static String formatPercent(double percent) {
    return _percentFormat.format(percent);
  }

  static String formatDistance(double distance) {
    return '${_distanceFormat.format(distance)} km';
  }

  static String getRelativeTimeString(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  static String getRemainingTimeString(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 30) {
        return 'Overdue by ${(absDifference.inDays / 30).floor()} months';
      } else {
        return 'Overdue by ${absDifference.inDays} days';
      }
    } else {
      if (difference.inDays > 30) {
        return 'Due in ${(difference.inDays / 30).floor()} months';
      } else if (difference.inDays > 0) {
        return 'Due in ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'Due in ${difference.inHours} hours';
      } else {
        return 'Due today';
      }
    }
  }
}