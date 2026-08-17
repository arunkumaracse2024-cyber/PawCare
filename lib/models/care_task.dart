class CareTask {
  final String id;
  final String species;
  final String? breedId;
  final String category; // 'feeding', 'grooming', 'vet', 'dental'
  final String title;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'

  CareTask({
    required this.id,
    required this.species,
    this.breedId,
    required this.category,
    required this.title,
    required this.frequency,
  });

  factory CareTask.fromMap(Map<String, dynamic> map) {
    return CareTask(
      id: map['id'] ?? '',
      species: map['species'] ?? 'all',
      breedId: map['breedId'],
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      frequency: map['frequency'] ?? 'daily',
    );
  }
}
