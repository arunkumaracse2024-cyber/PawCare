class TimeSlot {
  final String id;
  final String vetUid;
  final DateTime date;
  final String startTime; // e.g. "09:00"
  final String endTime; // e.g. "09:30"
  final bool isBooked;

  TimeSlot({
    required this.id,
    required this.vetUid,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  TimeSlot copyWith({
    String? id,
    String? vetUid,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isBooked,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      vetUid: vetUid ?? this.vetUid,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vetUid': vetUid,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isBooked': isBooked,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'] ?? '',
      vetUid: map['vetUid'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isBooked: map['isBooked'] ?? false,
    );
  }
}
