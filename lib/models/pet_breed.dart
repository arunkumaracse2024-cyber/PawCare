class LifespanRange {
  final int min;
  final int max;

  LifespanRange({required this.min, required this.max});

  factory LifespanRange.fromJson(Map<String, dynamic> json) {
    return LifespanRange(
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

class WeightRange {
  final double min;
  final double max;

  WeightRange({required this.min, required this.max});

  factory WeightRange.fromJson(Map<String, dynamic> json) {
    return WeightRange(
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

class HeightRange {
  final double min;
  final double max;

  HeightRange({required this.min, required this.max});

  factory HeightRange.fromJson(Map<String, dynamic> json) {
    return HeightRange(
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

class PetBreed {
  final String id;
  final String species;
  final String breed;
  final String origin;
  
  // Handled differently depending on the schema version. The new schema asks for object, but old cats/dogs.json have strings.
  // We'll support both in fromJson.
  final LifespanRange? lifespanYears; 
  final String? lifespanString; 

  final WeightRange? weightKg;
  final String? weightString; 

  final HeightRange? heightCm;
  final String? heightString; 

  final List<String> temperament;
  final String energyLevel;
  final String exerciseNeeds;
  final String groomingNeeds;
  final String climatePreference;
  final List<String> commonHealthConcerns;
  final String description;

  PetBreed({
    required this.id,
    required this.species,
    required this.breed,
    required this.origin,
    this.lifespanYears,
    this.lifespanString,
    this.weightKg,
    this.weightString,
    this.heightCm,
    this.heightString,
    required this.temperament,
    required this.energyLevel,
    required this.exerciseNeeds,
    required this.groomingNeeds,
    required this.climatePreference,
    required this.commonHealthConcerns,
    required this.description,
  });

  factory PetBreed.fromJson(Map<String, dynamic> json) {
    return PetBreed(
      id: json['id']?.toString() ?? '',
      species: json['species']?.toString().toLowerCase() ?? '',
      breed: json['breed']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      
      lifespanYears: json['lifespanYears'] != null && json['lifespanYears'] is Map<String, dynamic> 
          ? LifespanRange.fromJson(json['lifespanYears'] as Map<String, dynamic>) 
          : null,
      lifespanString: json['lifespan']?.toString(),

      weightKg: json['weightKg'] != null && json['weightKg'] is Map<String, dynamic> 
          ? WeightRange.fromJson(json['weightKg'] as Map<String, dynamic>) 
          : null,
      weightString: json['weight']?.toString(),

      heightCm: json['heightCm'] != null && json['heightCm'] is Map<String, dynamic> 
          ? HeightRange.fromJson(json['heightCm'] as Map<String, dynamic>) 
          : null,
      heightString: json['height']?.toString(),

      temperament: (json['temperament'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      
      // Fallbacks to handle both the strict new schema and the existing ones
      energyLevel: json['energyLevel']?.toString() ?? json['activityLevel']?.toString() ?? '',
      exerciseNeeds: json['exerciseNeeds']?.toString() ?? json['activityLevel']?.toString() ?? '',
      groomingNeeds: json['groomingNeeds']?.toString() ?? '',
      climatePreference: json['climatePreference']?.toString() ?? json['climate']?.toString() ?? '',
      commonHealthConcerns: (json['commonHealthConcerns'] as List<dynamic>?)?.map((e) => e.toString()).toList() 
          ?? (json['commonDiseases'] as List<dynamic>?)?.map((e) => e.toString()).toList() 
          ?? [],
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species': species,
      'breed': breed,
      'origin': origin,
      if (lifespanYears != null) 'lifespanYears': lifespanYears!.toJson(),
      if (lifespanString != null) 'lifespan': lifespanString,
      if (weightKg != null) 'weightKg': weightKg!.toJson(),
      if (weightString != null) 'weight': weightString,
      if (heightCm != null) 'heightCm': heightCm!.toJson(),
      if (heightString != null) 'height': heightString,
      'temperament': temperament,
      'energyLevel': energyLevel,
      'exerciseNeeds': exerciseNeeds,
      'groomingNeeds': groomingNeeds,
      'climatePreference': climatePreference,
      'commonHealthConcerns': commonHealthConcerns,
      'description': description,
    };
  }
}
