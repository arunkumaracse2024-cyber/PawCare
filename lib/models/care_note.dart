class CareNote {
  final String id;
  final String petId;
  final String source; // breedStandard, shop, vet
  final String category; // vaccination, feeding, grooming, medicine, checkup
  final String title;
  final String description;
  final DateTime date;
  final String sourceLabel; // e.g. "Standard care", "From your shop", "From Dr. Smith's visit"
  final String? appointmentId;
  final bool isResolved;

  CareNote({
    required this.id,
    required this.petId,
    required this.source,
    required this.category,
    required this.title,
    required this.description,
    required this.date,
    required this.sourceLabel,
    this.appointmentId,
    required this.isResolved,
  });

  CareNote copyWith({
    String? id,
    String? petId,
    String? source,
    String? category,
    String? title,
    String? description,
    DateTime? date,
    String? sourceLabel,
    String? appointmentId,
    bool? isResolved,
  }) {
    return CareNote(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      source: source ?? this.source,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      appointmentId: appointmentId ?? this.appointmentId,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'source': source,
      'category': category,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'sourceLabel': sourceLabel,
      'appointmentId': appointmentId,
      'isResolved': isResolved,
    };
  }

  factory CareNote.fromMap(Map<String, dynamic> map) {
    return CareNote(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      source: map['source'] ?? 'breedStandard',
      category: map['category'] ?? 'checkup',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      sourceLabel: map['sourceLabel'] ?? '',
      appointmentId: map['appointmentId'],
      isResolved: map['isResolved'] ?? false,
    );
  }
}
