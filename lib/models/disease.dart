class Disease {
  final String id;
  final String targetSpecies;
  final List<String> requiredSymptoms;
  final List<String> anySymptoms;
  final bool youngOnly;
  final bool longDurationOnly;
  final String level;
  final String title;
  final String guideline;
  final List<String> actions;

  Disease({
    required this.id,
    required this.targetSpecies,
    required this.requiredSymptoms,
    required this.anySymptoms,
    required this.youngOnly,
    required this.longDurationOnly,
    required this.level,
    required this.title,
    required this.guideline,
    required this.actions,
  });

  factory Disease.fromMap(Map<String, dynamic> map) {
    return Disease(
      id: map['id'] ?? '',
      targetSpecies: map['targetSpecies'] ?? 'all',
      requiredSymptoms: List<String>.from(map['requiredSymptoms'] ?? []),
      anySymptoms: List<String>.from(map['anySymptoms'] ?? []),
      youngOnly: map['youngOnly'] ?? false,
      longDurationOnly: map['longDurationOnly'] ?? false,
      level: map['level'] ?? 'caution',
      title: map['title'] ?? '',
      guideline: map['guideline'] ?? '',
      actions: List<String>.from(map['actions'] ?? []),
    );
  }
}
