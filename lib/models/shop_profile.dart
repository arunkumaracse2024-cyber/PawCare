class ShopProfile {
  final String uid;
  final String shopName;
  final String address;
  final List<String> partnerVetIds;

  ShopProfile({
    required this.uid,
    required this.shopName,
    required this.address,
    required this.partnerVetIds,
  });

  ShopProfile copyWith({
    String? uid,
    String? shopName,
    String? address,
    List<String>? partnerVetIds,
  }) {
    return ShopProfile(
      uid: uid ?? this.uid,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      partnerVetIds: partnerVetIds ?? this.partnerVetIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'address': address,
      'partnerVetIds': partnerVetIds,
    };
  }

  factory ShopProfile.fromMap(Map<String, dynamic> map) {
    return ShopProfile(
      uid: map['uid'] ?? '',
      shopName: map['shopName'] ?? '',
      address: map['address'] ?? '',
      partnerVetIds: List<String>.from(map['partnerVetIds'] ?? []),
    );
  }
}
