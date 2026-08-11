class PetDisease {
  final String id;
  final String species;
  final String diseaseName;
  final List<String> symptoms;
  final List<String> possibleCauses;
  final List<String> prevention;
  final String severity; // low, moderate, high
  final String whenToSeeVet;
  final String description;

  PetDisease({
    required this.id,
    required this.species,
    required this.diseaseName,
    required this.symptoms,
    required this.possibleCauses,
    required this.prevention,
    required this.severity,
    required this.whenToSeeVet,
    required this.description,
  });

  factory PetDisease.fromJson(Map<String, dynamic> json) {
    return PetDisease(
      id: json['id']?.toString() ?? '',
      species: json['species']?.toString().toLowerCase() ?? '',
      diseaseName: json['diseaseName']?.toString() ?? '',
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      possibleCauses: (json['possibleCauses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      prevention: (json['prevention'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      severity: json['severity']?.toString().toLowerCase() ?? 'moderate',
      whenToSeeVet: json['whenToSeeVet']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species': species,
      'diseaseName': diseaseName,
      'symptoms': symptoms,
      'possibleCauses': possibleCauses,
      'prevention': prevention,
      'severity': severity,
      'whenToSeeVet': whenToSeeVet,
      'description': description,
    };
  }
}
