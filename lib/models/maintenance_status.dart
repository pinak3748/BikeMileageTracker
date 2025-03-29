enum MaintenanceStatus {
  pending,
  completed,
  skipped;

  static MaintenanceStatus fromString(String value) {
    return MaintenanceStatus.values.firstWhere(
      (element) => element.toString() == 'MaintenanceStatus.$value',
      orElse: () => MaintenanceStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.skipped:
        return 'Skipped';
    }
  }
}