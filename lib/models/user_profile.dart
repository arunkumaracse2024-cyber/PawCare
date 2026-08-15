class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role; // owner, shop, vet
  final bool hasCompletedOnboarding;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.hasCompletedOnboarding,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'owner',
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
