class Appointment {
  final String id;
  final String petId;
  final String ownerUid;
  final String vetUid;
  final String? shopId;
  final DateTime dateTime;
  final String slotId;
  final String status; // pending, accepted, rejected, completed
  final String notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.petId,
    required this.ownerUid,
    required this.vetUid,
    this.shopId,
    required this.dateTime,
    required this.slotId,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  Appointment copyWith({
    String? id,
    String? petId,
    String? ownerUid,
    String? vetUid,
    String? shopId,
    DateTime? dateTime,
    String? slotId,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      ownerUid: ownerUid ?? this.ownerUid,
      vetUid: vetUid ?? this.vetUid,
      shopId: shopId ?? this.shopId,
      dateTime: dateTime ?? this.dateTime,
      slotId: slotId ?? this.slotId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'ownerUid': ownerUid,
      'vetUid': vetUid,
      'shopId': shopId,
      'dateTime': dateTime.toIso8601String(),
      'slotId': slotId,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      vetUid: map['vetUid'] ?? '',
      shopId: map['shopId'],
      dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
      slotId: map['slotId'] ?? '',
      status: map['status'] ?? 'pending',
      notes: map['notes'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
