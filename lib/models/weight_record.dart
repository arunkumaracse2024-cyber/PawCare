class WeightRecord {
  final String id;
  final String petId;
  final double weight;
  final DateTime date;
  final String notes;

  WeightRecord({
    required this.id,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes = '',
  });

  WeightRecord copyWith({
    String? id,
    String? petId,
    double? weight,
    DateTime? date,
    String? notes,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      weight: (map['weight'] is num) ? (map['weight'] as num).toDouble() : 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      notes: map['notes'] ?? '',
    );
  }
}
