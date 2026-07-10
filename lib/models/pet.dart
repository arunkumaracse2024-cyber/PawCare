class Pet {
  final String id;
  final String name;
  final String species; // dog, cat, bird
  final String breed;
  final double age; // years
  final double weight; // kg
  final String photoPath;
  final List<ChecklistItem> checklist;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.photoPath,
    required this.checklist,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    double? age,
    double? weight,
    String? photoPath,
    List<ChecklistItem>? checklist,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      photoPath: photoPath ?? this.photoPath,
      checklist: checklist ?? this.checklist,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'photoPath': photoPath,
      'checklist': checklist.map((item) => item.toMap()).toList(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      age: (map['age'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      photoPath: map['photoPath'] ?? '',
      checklist:
          (map['checklist'] as List<dynamic>?)
              ?.map(
                (item) => ChecklistItem.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String category; // Day 1, Week 1, Month 1
  final bool isDone;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    required this.isDone,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? category,
    bool? isDone,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'category': category, 'isDone': isDone};
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}
