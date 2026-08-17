class BehaviourTrait {
  final String id;
  final String species;
  final String category; // e.g. "Vocalization", "Social", "Activity"
  final String traitName;
  final String description;

  BehaviourTrait({
    required this.id,
    required this.species,
    required this.category,
    required this.traitName,
    required this.description,
  });

  factory BehaviourTrait.fromMap(Map<String, dynamic> map) {
    return BehaviourTrait(
      id: map['id'] ?? '',
      species: map['species'] ?? 'all',
      category: map['category'] ?? 'General',
      traitName: map['traitName'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
