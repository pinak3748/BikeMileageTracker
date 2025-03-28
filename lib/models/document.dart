class Document {
  final int? id;
  final int bikeId;
  final String title;
  final String documentType;
  final DateTime date;
  final DateTime? expiryDate;
  final String filePath;
  final String? notes;

  Document({
    this.id,
    required this.bikeId,
    required this.title,
    required this.documentType,
    required this.date,
    this.expiryDate,
    required this.filePath,
    this.notes,
  });

  Document copyWith({
    int? id,
    int? bikeId,
    String? title,
    String? documentType,
    DateTime? date,
    DateTime? expiryDate,
    String? filePath,
    String? notes,
  }) {
    return Document(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      date: date ?? this.date,
      expiryDate: expiryDate ?? this.expiryDate,
      filePath: filePath ?? this.filePath,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bike_id': bikeId,
      'title': title,
      'document_type': documentType,
      'date': date.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'file_path': filePath,
      'notes': notes,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      bikeId: map['bike_id'],
      title: map['title'],
      documentType: map['document_type'],
      date: DateTime.parse(map['date']),
      expiryDate: map['expiry_date'] != null ? DateTime.parse(map['expiry_date']) : null,
      filePath: map['file_path'],
      notes: map['notes'],
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
  
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  @override
  String toString() {
    return 'Document{id: $id, title: $title, documentType: $documentType, date: $date, expiryDate: $expiryDate}';
  }
}
