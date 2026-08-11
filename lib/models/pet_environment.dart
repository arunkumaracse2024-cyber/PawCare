class PetEnvironment {
  final String id;
  final String species;
  final String temperatureGuidance;
  final String humidityGuidance;
  final String exerciseNeeds;
  final String sleepNeeds;
  final String livingSpace;
  final String ventilation;
  final String groomingFrequency;
  final List<String> specialConsiderations;

  PetEnvironment({
    required this.id,
    required this.species,
    required this.temperatureGuidance,
    required this.humidityGuidance,
    required this.exerciseNeeds,
    required this.sleepNeeds,
    required this.livingSpace,
    required this.ventilation,
    required this.groomingFrequency,
    required this.specialConsiderations,
  });

  factory PetEnvironment.fromJson(Map<String, dynamic> json) {
    return PetEnvironment(
      id: json['id']?.toString() ?? '',
      species: json['species']?.toString().toLowerCase() ?? '',
      temperatureGuidance: json['temperatureGuidance']?.toString() ?? '',
      humidityGuidance: json['humidityGuidance']?.toString() ?? '',
      exerciseNeeds: json['exerciseNeeds']?.toString() ?? '',
      sleepNeeds: json['sleepNeeds']?.toString() ?? '',
      livingSpace: json['livingSpace']?.toString() ?? '',
      ventilation: json['ventilation']?.toString() ?? '',
      groomingFrequency: json['groomingFrequency']?.toString() ?? '',
      specialConsiderations: (json['specialConsiderations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species': species,
      'temperatureGuidance': temperatureGuidance,
      'humidityGuidance': humidityGuidance,
      'exerciseNeeds': exerciseNeeds,
      'sleepNeeds': sleepNeeds,
      'livingSpace': livingSpace,
      'ventilation': ventilation,
      'groomingFrequency': groomingFrequency,
      'specialConsiderations': specialConsiderations,
    };
  }
}
