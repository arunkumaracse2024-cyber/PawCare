class PetGrowthStage {
  final String id;
  final String species;
  final String stage; // e.g., puppy, kitten, adult, senior
  final String ageRange;
  final String feedingGuidance;
  final String exerciseGuidance;
  final String trainingGuidance;
  final List<String> healthChecks;
  final List<String> careChecklist;

  PetGrowthStage({
    required this.id,
    required this.species,
    required this.stage,
    required this.ageRange,
    required this.feedingGuidance,
    required this.exerciseGuidance,
    required this.trainingGuidance,
    required this.healthChecks,
    required this.careChecklist,
  });

  factory PetGrowthStage.fromJson(Map<String, dynamic> json) {
    return PetGrowthStage(
      id: json['id']?.toString() ?? '',
      species: json['species']?.toString().toLowerCase() ?? '',
      stage: json['stage']?.toString().toLowerCase() ?? '',
      ageRange: json['ageRange']?.toString() ?? '',
      feedingGuidance: json['feedingGuidance']?.toString() ?? '',
      exerciseGuidance: json['exerciseGuidance']?.toString() ?? '',
      trainingGuidance: json['trainingGuidance']?.toString() ?? '',
      healthChecks: (json['healthChecks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      careChecklist: (json['careChecklist'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species': species,
      'stage': stage,
      'ageRange': ageRange,
      'feedingGuidance': feedingGuidance,
      'exerciseGuidance': exerciseGuidance,
      'trainingGuidance': trainingGuidance,
      'healthChecks': healthChecks,
      'careChecklist': careChecklist,
    };
  }
}
