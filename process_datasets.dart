import 'dart:convert';
import 'dart:io';

void main() async {
  final outDir = Directory('assets/data');
  if (!await outDir.exists()) {
    await outDir.create(recursive: true);
  }

  // Merge breeds
  final List<dynamic> allBreeds = [];
  
  final catsFile = File('dataset/breeds/cats.json');
  if (await catsFile.exists()) {
    final content = await catsFile.readAsString();
    final List<dynamic> cats = jsonDecode(content);
    allBreeds.addAll(cats);
  }

  final dogsFile = File('dataset/breeds/dogs.json');
  if (await dogsFile.exists()) {
    final content = await dogsFile.readAsString();
    final List<dynamic> dogs = jsonDecode(content);
    allBreeds.addAll(dogs);
  }

  await File('assets/data/breeds.json').writeAsString(jsonEncode(allBreeds));

  // Create empty arrays for missing datasets
  final missingDatasets = [
    'foods.json',
    'vaccines.json',
    'diseases.json',
    'behaviours.json',
    'environments.json',
    'growth_stages.json',
    'care_guides.json'
  ];

  for (final file in missingDatasets) {
    if (!await File('assets/data/$file').exists()) {
      await File('assets/data/$file').writeAsString('[]');
    }
  }

  print('Datasets processed.');
}
