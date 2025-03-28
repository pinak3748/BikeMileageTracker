class Expense {
  final int? id;
  final int bikeId;
  final DateTime date;
  final String category;
  final String title;
  final double amount;
  final String? notes;
  final String? receiptUrl;
  final double? odometer;

  Expense({
    this.id,
    required this.bikeId,
    required this.date,
    required this.category,
    required this.title,
    required this.amount,
    this.notes,
    this.receiptUrl,
    this.odometer,
  });

  Expense copyWith({
    int? id,
    int? bikeId,
    DateTime? date,
    String? category,
    String? title,
    double? amount,
    String? notes,
    String? receiptUrl,
    double? odometer,
  }) {
    return Expense(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      category: category ?? this.category,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      odometer: odometer ?? this.odometer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bike_id': bikeId,
      'date': date.toIso8601String(),
      'category': category,
      'title': title,
      'amount': amount,
      'notes': notes,
      'receipt_url': receiptUrl,
      'odometer': odometer,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      bikeId: map['bike_id'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      title: map['title'],
      amount: map['amount'],
      notes: map['notes'],
      receiptUrl: map['receipt_url'],
      odometer: map['odometer'],
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, date: $date, category: $category, title: $title, amount: $amount}';
  }
}
