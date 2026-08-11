class CareChecklistItem {
  final String title;
  final String description;

  CareChecklistItem({required this.title, required this.description});

  factory CareChecklistItem.fromJson(Map<String, dynamic> json) {
    return CareChecklistItem(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };
}

class PetCareGuide {
  final String id;
  final String species;
  final String lifeStage;
  final String category; // e.g., new_pet
  final String title;
  final String description;
  final String priority; // low, moderate, high
  final String recommendedTiming;
  final List<CareChecklistItem> checklistItems;

  PetCareGuide({
    required this.id,
    required this.species,
    required this.lifeStage,
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    required this.recommendedTiming,
    required this.checklistItems,
  });

  factory PetCareGuide.fromJson(Map<String, dynamic> json) {
    return PetCareGuide(
      id: json['id']?.toString() ?? '',
      species: json['species']?.toString().toLowerCase() ?? '',
      lifeStage: json['lifeStage']?.toString().toLowerCase() ?? '',
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString().toLowerCase() ?? 'moderate',
      recommendedTiming: json['recommendedTiming']?.toString() ?? '',
      checklistItems: (json['checklistItems'] as List<dynamic>?)
          ?.map((e) => CareChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species': species,
      'lifeStage': lifeStage,
      'category': category,
      'title': title,
      'description': description,
      'priority': priority,
      'recommendedTiming': recommendedTiming,
      'checklistItems': checklistItems.map((e) => e.toJson()).toList(),
    };
  }
}
