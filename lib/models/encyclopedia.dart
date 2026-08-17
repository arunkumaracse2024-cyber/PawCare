class Breed {
  final String id;
  final String species;
  final String name;
  final String temperament;
  final String lifespan;
  final String sizeRange;
  final String careGuide;
  final String funFact;

  Breed({
    required this.id,
    required this.species,
    required this.name,
    required this.temperament,
    required this.lifespan,
    required this.sizeRange,
    required this.careGuide,
    required this.funFact,
  });

  factory Breed.fromMap(Map<String, dynamic> map) {
    return Breed(
      id: map['id'] ?? '',
      species: map['species'] ?? 'all',
      name: map['name'] ?? '',
      temperament: map['temperament'] ?? '',
      lifespan: map['lifespan'] ?? '',
      sizeRange: map['sizeRange'] ?? '',
      careGuide: map['careGuide'] ?? '',
      funFact: map['funFact'] ?? '',
    );
  }
}

class Species {
  final String id;
  final String name;

  Species({
    required this.id,
    required this.name,
  });

  factory Species.fromMap(Map<String, dynamic> map) {
    return Species(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}

class VaccineTemplate {
  final String id;
  final String species;
  final String name;
  final String suggestedAge;

  VaccineTemplate({
    required this.id,
    required this.species,
    required this.name,
    required this.suggestedAge,
  });

  factory VaccineTemplate.fromMap(Map<String, dynamic> map) {
    return VaccineTemplate(
      id: map['id'] ?? '',
      species: map['species'] ?? 'all',
      name: map['name'] ?? '',
      suggestedAge: map['suggestedAge'] ?? '',
    );
  }
}
