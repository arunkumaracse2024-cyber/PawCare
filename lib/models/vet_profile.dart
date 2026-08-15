class VetProfile {
  final String uid;
  final String clinicName;
  final String address;
  final String specialization;
  final Map<String, dynamic> workingHours; // e.g. {"Mon": "09:00-17:00", ...}
  final bool isVerified;
  final List<String> partnerShopIds;

  VetProfile({
    required this.uid,
    required this.clinicName,
    required this.address,
    required this.specialization,
    required this.workingHours,
    required this.isVerified,
    required this.partnerShopIds,
  });

  VetProfile copyWith({
    String? uid,
    String? clinicName,
    String? address,
    String? specialization,
    Map<String, dynamic>? workingHours,
    bool? isVerified,
    List<String>? partnerShopIds,
  }) {
    return VetProfile(
      uid: uid ?? this.uid,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      specialization: specialization ?? this.specialization,
      workingHours: workingHours ?? this.workingHours,
      isVerified: isVerified ?? this.isVerified,
      partnerShopIds: partnerShopIds ?? this.partnerShopIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'clinicName': clinicName,
      'address': address,
      'specialization': specialization,
      'workingHours': workingHours,
      'isVerified': isVerified,
      'partnerShopIds': partnerShopIds,
    };
  }

  factory VetProfile.fromMap(Map<String, dynamic> map) {
    return VetProfile(
      uid: map['uid'] ?? '',
      clinicName: map['clinicName'] ?? '',
      address: map['address'] ?? '',
      specialization: map['specialization'] ?? '',
      workingHours: Map<String, dynamic>.from(map['workingHours'] ?? {}),
      isVerified: map['isVerified'] ?? false,
      partnerShopIds: List<String>.from(map['partnerShopIds'] ?? []),
    );
  }
}
