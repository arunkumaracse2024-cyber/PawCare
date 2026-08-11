class PetBehaviour {
  final String id;
  final String species;
  final String behaviour;
  final String category; // positive, normal, concerning, aggressive
  final String possibleMeaning;
  final List<String> possibleReasons;
  final String recommendedOwnerAction;

  PetBehaviour({
    required this.id,
    required this.species,
    required this.behaviour,
    required this.category,
    required this.possibleMeaning,
    required this.possibleReasons,
    required this.recommendedOwnerAction,
  });

  factory PetBehaviour.fromJson(Map<String, dynamic> json) {
    return PetBehaviour(
      id: json['id']?.toString() ?? '',
      species: json['species']?.toString().toLowerCase() ?? '',
      behaviour: json['behaviour']?.toString() ?? '',
      category: json['category']?.toString().toLowerCase() ?? 'normal',
      possibleMeaning: json['possibleMeaning']?.toString() ?? '',
      possibleReasons: (json['possibleReasons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendedOwnerAction: json['recommendedOwnerAction']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species': species,
      'behaviour': behaviour,
      'category': category,
      'possibleMeaning': possibleMeaning,
      'possibleReasons': possibleReasons,
      'recommendedOwnerAction': recommendedOwnerAction,
    };
  }
}
