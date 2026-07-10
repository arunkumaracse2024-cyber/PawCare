class PetReminder {
  final String id;
  final String petId;
  final String title;
  final String type; // Vaccine, Medicine, Grooming, Feeding
  final DateTime dateTime;
  final String repeatOption; // None, Daily, Weekly, Monthly
  final bool isDone;

  PetReminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.repeatOption,
    required this.isDone,
  });

  PetReminder copyWith({
    String? id,
    String? petId,
    String? title,
    String? type,
    DateTime? dateTime,
    String? repeatOption,
    bool? isDone,
  }) {
    return PetReminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      repeatOption: repeatOption ?? this.repeatOption,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'repeatOption': repeatOption,
      'isDone': isDone,
    };
  }

  factory PetReminder.fromMap(Map<String, dynamic> map) {
    return PetReminder(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
      repeatOption: map['repeatOption'] ?? 'None',
      isDone: map['isDone'] ?? false,
    );
  }
}
