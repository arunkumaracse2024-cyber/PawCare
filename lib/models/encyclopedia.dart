class Breed {
  final String id;
  final String name;
  final String temperament;
  final String lifespan;
  final String sizeRange;
  final String careGuide;
  final String funFact;

  Breed({
    required this.id,
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
  final List<String> safeFoods;
  final List<String> unsafeFoods;
  final List<Breed> breeds;
  final List<VaccineTemplate> recommendedVaccines;

  Species({
    required this.id,
    required this.name,
    required this.safeFoods,
    required this.unsafeFoods,
    required this.breeds,
    required this.recommendedVaccines,
  });

  factory Species.fromMap(Map<String, dynamic> map) {
    var commonFoods = map['commonFoods'] as Map<String, dynamic>? ?? {};
    return Species(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      safeFoods: List<String>.from(commonFoods['safe'] ?? []),
      unsafeFoods: List<String>.from(commonFoods['unsafe'] ?? []),
      breeds:
          (map['breeds'] as List<dynamic>?)
              ?.map((b) => Breed.fromMap(b as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedVaccines:
          (map['vaccinations'] as List<dynamic>?)
              ?.map((v) => VaccineTemplate.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class VaccineTemplate {
  final String name;
  final String suggestedAge;

  VaccineTemplate({required this.name, required this.suggestedAge});

  factory VaccineTemplate.fromMap(Map<String, dynamic> map) {
    return VaccineTemplate(
      name: map['name'] ?? '',
      suggestedAge: map['suggestedAge'] ?? '',
    );
  }
}
