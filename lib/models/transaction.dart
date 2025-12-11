class Transaction {
  final int? id;
  final String type; // 'income' or 'expense'
  final double amount;
  final String description;
  final String? category;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.category,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: map['amount'] as double,
      description: map['description'] as String,
      category: map['category'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Transaction copyWith({
    int? id,
    String? type,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
