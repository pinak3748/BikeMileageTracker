/// Enum representing the type of fuel fill-up
enum FillType {
  /// A full tank fill-up (tank was filled completely)
  full,
  
  /// A partial tank fill-up (tank was not filled completely)
  partial;
  
  /// Get a displayable string for the enum value
  String get displayName {
    switch (this) {
      case FillType.full:
        return 'Full Tank';
      case FillType.partial:
        return 'Partial Fill';
    }
  }
  
  /// Convert string to enum value
  static FillType fromString(String? value) {
    if (value == null) return FillType.full;
    
    switch (value.toLowerCase()) {
      case 'full':
      case 'full tank':
      case 'complete':
        return FillType.full;
      case 'partial':
      case 'partial fill':
      case 'incomplete':
        return FillType.partial;
      default:
        return FillType.full;
    }
  }
}