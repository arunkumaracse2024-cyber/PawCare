class PetVaccine {
  final String id;
  final String species;
  final String vaccineName;
  final String lifeStage;
  final String recommendedAge;
  final String boosterInformation;
  final String purpose;
  final String notes;
  final bool requiresVeterinarian;

  PetVaccine({
    required this.id,
    required this.species,
    required this.vaccineName,
    required this.lifeStage,
    required this.recommendedAge,
    required this.boosterInformation,
    required this.purpose,
    required this.notes,
    required this.requiresVeterinarian,
  });

  factory PetVaccine.fromJson(Map<String, dynamic> json) {
    return PetVaccine(
      id: json['id']?.toString() ?? '',
      species: json['species']?.toString().toLowerCase() ?? '',
      vaccineName: json['vaccineName']?.toString() ?? '',
      lifeStage: json['lifeStage']?.toString().toLowerCase() ?? '',
      recommendedAge: json['recommendedAge']?.toString() ?? '',
      boosterInformation: json['boosterInformation']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      requiresVeterinarian: json['requiresVeterinarian'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species': species,
      'vaccineName': vaccineName,
      'lifeStage': lifeStage,
      'recommendedAge': recommendedAge,
      'boosterInformation': boosterInformation,
      'purpose': purpose,
      'notes': notes,
      'requiresVeterinarian': requiresVeterinarian,
    };
  }
}
