class PetFood {
  final String id;
  final String foodName;
  final List<String> species; // lowercased
  final String classification; // safe, caution, toxic
  final String riskLevel; // low, moderate, high
  final String reason;
  final String? safePreparation;
  final String notes;

  PetFood({
    required this.id,
    required this.foodName,
    required this.species,
    required this.classification,
    required this.riskLevel,
    required this.reason,
    this.safePreparation,
    required this.notes,
  });

  factory PetFood.fromJson(Map<String, dynamic> json) {
    return PetFood(
      id: json['id']?.toString() ?? '',
      foodName: json['foodName']?.toString() ?? '',
      species: (json['species'] as List<dynamic>?)?.map((e) => e.toString().toLowerCase()).toList() ?? [],
      classification: json['classification']?.toString().toLowerCase() ?? 'caution',
      riskLevel: json['riskLevel']?.toString().toLowerCase() ?? 'moderate',
      reason: json['reason']?.toString() ?? '',
      safePreparation: json['safePreparation']?.toString(),
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'species': species,
      'classification': classification,
      'riskLevel': riskLevel,
      'reason': reason,
      'safePreparation': safePreparation,
      'notes': notes,
    };
  }
}
