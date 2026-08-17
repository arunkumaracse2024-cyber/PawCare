// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    print('Data directory not found!');
    exit(1);
  }

  bool allValid = true;

  void validateFile(String filename, String rootKey, List<String> requiredFields) {
    final file = File('${dataDir.path}/$filename');
    if (!file.existsSync()) {
      print('Missing $filename');
      allValid = false;
      return;
    }

    try {
      final content = file.readAsStringSync();
      final data = json.decode(content);
      if (data[rootKey] == null || data[rootKey] is! List) {
        print('Invalid root key or not a list in $filename: $rootKey');
        allValid = false;
        return;
      }

      final list = data[rootKey] as List;
      final ids = <String>{};

      for (var item in list) {
        if (item is! Map) {
          print('Item is not a map in $filename');
          allValid = false;
          continue;
        }
        for (var field in requiredFields) {
          if (!item.containsKey(field) || item[field] == null || (item[field] is String && item[field].toString().isEmpty)) {
            print('Missing or empty required field $field in $filename');
            allValid = false;
          }
        }
        
        if (item.containsKey('id')) {
          if (ids.contains(item['id'])) {
            print('Duplicate ID found in $filename: ${item['id']}');
            allValid = false;
          }
          ids.add(item['id']);
        }
      }
    } catch (e) {
      print('Error parsing $filename: $e');
      allValid = false;
    }
  }

  validateFile('species.json', 'species', ['id', 'name']);
  validateFile('breeds.json', 'breeds', ['id', 'species', 'name']);
  validateFile('foods.json', 'foods', ['id', 'species', 'name', 'isSafe']);
  validateFile('vaccines.json', 'vaccines', ['id', 'species', 'name', 'suggestedAge']);
  validateFile('diseases.json', 'diseases', ['id', 'targetSpecies', 'level', 'title', 'guideline', 'actions']);
  validateFile('behaviours.json', 'behaviours', ['id', 'species', 'category', 'traitName', 'description']);
  validateFile('care_guides.json', 'care_tasks', ['id', 'species', 'category', 'title', 'frequency']);
  validateFile('growth_stages.json', 'growth_stages', ['id', 'species', 'stageName', 'ageRange', 'description']);
  validateFile('environments.json', 'environments', ['id', 'species', 'title', 'description']);

  if (allValid) {
    print('All JSON files validated successfully.');
    exit(0);
  } else {
    print('JSON validation failed.');
    exit(1);
  }
}
