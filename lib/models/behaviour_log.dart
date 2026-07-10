class BehaviourLog {
  final String id;
  final String petId;
  final DateTime date;
  final String eatingStatus; // Poor, Normal, Great
  final int activityLevel; // 1-5
  final double sleepHours; // 0-24
  final String notes;

  BehaviourLog({
    required this.id,
    required this.petId,
    required this.date,
    required this.eatingStatus,
    required this.activityLevel,
    required this.sleepHours,
    required this.notes,
  });

  BehaviourLog copyWith({
    String? id,
    String? petId,
    DateTime? date,
    String? eatingStatus,
    int? activityLevel,
    double? sleepHours,
    String? notes,
  }) {
    return BehaviourLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      eatingStatus: eatingStatus ?? this.eatingStatus,
      activityLevel: activityLevel ?? this.activityLevel,
      sleepHours: sleepHours ?? this.sleepHours,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'eatingStatus': eatingStatus,
      'activityLevel': activityLevel,
      'sleepHours': sleepHours,
      'notes': notes,
    };
  }

  factory BehaviourLog.fromMap(Map<String, dynamic> map) {
    return BehaviourLog(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      eatingStatus: map['eatingStatus'] ?? 'Normal',
      activityLevel: (map['activityLevel'] is num)
          ? (map['activityLevel'] as num).toInt()
          : int.tryParse(map['activityLevel']?.toString() ?? '') ?? 3,
      sleepHours: (map['sleepHours'] is num)
          ? (map['sleepHours'] as num).toDouble()
          : double.tryParse(map['sleepHours']?.toString() ?? '') ?? 8.0,
      notes: map['notes'] ?? '',
    );
  }
}
