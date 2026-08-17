class EnvironmentRecommendation {
  final String id;
  final String species;
  final String title;
  final String description;

  EnvironmentRecommendation({
    required this.id,
    required this.species,
    required this.title,
    required this.description,
  });

  factory EnvironmentRecommendation.fromMap(Map<String, dynamic> map) {
    return EnvironmentRecommendation(
      id: map['id'] ?? '',
      species: map['species'] ?? 'all',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
