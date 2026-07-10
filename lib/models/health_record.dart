class HealthRecord {
  final String id;
  final String petId;
  final String title;
  final String type; // Vaccine, Prescription, Medical Report
  final DateTime date;
  final String details;
  final String? attachmentPath; // Local path to PDF or image

  HealthRecord({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.date,
    required this.details,
    this.attachmentPath,
  });

  HealthRecord copyWith({
    String? id,
    String? petId,
    String? title,
    String? type,
    DateTime? date,
    String? details,
    String? attachmentPath,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      type: type ?? this.type,
      date: date ?? this.date,
      details: details ?? this.details,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'type': type,
      'date': date.toIso8601String(),
      'details': details,
      'attachmentPath': attachmentPath,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      details: map['details'] ?? '',
      attachmentPath: map['attachmentPath'],
    );
  }
}
