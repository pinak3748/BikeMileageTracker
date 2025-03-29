class Expense {
  final String? id;
  final String bikeId;
  final String category;
  final String title;
  final DateTime date;
  final double amount;
  final double? odometer;
  final String? vendor;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final String? receiptUrl;

  Expense({
    this.id,
    required this.bikeId,
    required this.category,
    required this.title,
    required this.date,
    required this.amount,
    this.odometer,
    this.vendor,
    this.description,
    this.notes,
    this.receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Expense copyWith({
    String? id,
    String? bikeId,
    String? category,
    String? title,
    DateTime? date,
    double? amount,
    double? odometer,
    String? vendor,
    String? description,
    String? notes,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      category: category ?? this.category,
      title: title ?? this.title,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      odometer: odometer ?? this.odometer,
      vendor: vendor ?? this.vendor,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bike_id': bikeId,
      'category': category,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'odometer': odometer,
      'vendor': vendor,
      'description': description,
      'notes': notes,
      'receipt_url': receiptUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      bikeId: map['bike_id'],
      category: map['category'],
      title: map['title'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      amount: map['amount'],
      odometer: map['odometer'],
      vendor: map['vendor'],
      description: map['description'],
      notes: map['notes'],
      receiptUrl: map['receipt_url'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}