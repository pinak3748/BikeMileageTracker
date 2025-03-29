enum ReminderType {
  none,
  date,
  odometer,
  both;

  static ReminderType fromString(String value) {
    return ReminderType.values.firstWhere(
      (element) => element.toString() == 'ReminderType.$value',
      orElse: () => ReminderType.none,
    );
  }

  String get displayName {
    switch (this) {
      case ReminderType.none:
        return 'No Reminder';
      case ReminderType.date:
        return 'Date-based';
      case ReminderType.odometer:
        return 'Odometer-based';
      case ReminderType.both:
        return 'Date and Odometer';
    }
  }
}