import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _shortDateFormat = DateFormat('M/d/yy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final NumberFormat _numberFormat = NumberFormat('#,##0.0#');
  static final NumberFormat _percentFormat = NumberFormat.percentPattern();
  
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }
  
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
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
  
  static String formatDistance(double km) {
    return '${formatNumber(km)} km';
  }
  
  static String formatFuelVolume(double liters) {
    return '${formatNumber(liters)} L';
  }
  
  static String formatFuelEconomy(double kmPerLiter) {
    return '${formatNumber(kmPerLiter)} km/L';
  }
  
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
  
  static String getDueInText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays < 0) {
      return 'Overdue by ${-difference.inDays} day${-difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays} days';
    } else if (difference.inDays < 30) {
      return 'Due in ${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? '' : 's'}';
    } else {
      return 'Due in ${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'}';
    }
  }
}