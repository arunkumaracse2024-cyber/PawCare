class Food {
  final String id;
  final String species;
  final String name;
  final bool isSafe;
  final String description; // optional

  Food({
    required this.id,
    required this.species,
    required this.name,
    required this.isSafe,
    required this.description,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] ?? '',
      species: map['species'] ?? 'all',
      name: map['name'] ?? '',
      isSafe: map['isSafe'] ?? false,
      description: map['description'] ?? '',
    );
  }
}
