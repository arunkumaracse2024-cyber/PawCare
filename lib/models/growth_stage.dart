class GrowthStage {
  final String id;
  final String species;
  final String stageName; // e.g. "Puppy", "Adult", "Senior"
  final String ageRange; // e.g. "0-6 months"
  final String description;

  GrowthStage({
    required this.id,
    required this.species,
    required this.stageName,
    required this.ageRange,
    required this.description,
  });

  factory GrowthStage.fromMap(Map<String, dynamic> map) {
    return GrowthStage(
      id: map['id'] ?? '',
      species: map['species'] ?? 'all',
      stageName: map['stageName'] ?? '',
      ageRange: map['ageRange'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
