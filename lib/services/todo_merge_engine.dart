import '../models/care_note.dart';

class MergedTodoItem {
  final String id;
  final String title;
  final String description;
  final String category; // vaccination, feeding, grooming, medicine, checkup
  final String source; // breedStandard, shop, vet
  final String sourceLabel;
  final bool isDone;
  final DateTime date;
  final bool isSatisfied;
  final String? supersededByTitle;

  MergedTodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.source,
    required this.sourceLabel,
    required this.isDone,
    required this.date,
    this.isSatisfied = false,
    this.supersededByTitle,
  });

  MergedTodoItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? source,
    String? sourceLabel,
    bool? isDone,
    DateTime? date,
    bool? isSatisfied,
    String? supersededByTitle,
  }) {
    return MergedTodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      source: source ?? this.source,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      isSatisfied: isSatisfied ?? this.isSatisfied,
      supersededByTitle: supersededByTitle ?? this.supersededByTitle,
    );
  }
}

class TodoMergeEngine {
  static List<MergedTodoItem> mergeTodos({
    required List<CareNote> breedStandardItems,
    required List<CareNote> shopNotes,
    required List<CareNote> vetInstructions,
  }) {
    final List<MergedTodoItem> mergedList = [];

    // Group items by category: vaccination, feeding, grooming, medicine, checkup
    final categories = ['vaccination', 'feeding', 'grooming', 'medicine', 'checkup'];

    for (final category in categories) {
      final categoryVet = vetInstructions.where((item) => item.category.toLowerCase() == category).toList();
      final categoryShop = shopNotes.where((item) => item.category.toLowerCase() == category).toList();
      final categoryStandard = breedStandardItems.where((item) => item.category.toLowerCase() == category).toList();

      if (categoryVet.isNotEmpty) {
        // Vet instructions are active
        for (final vetItem in categoryVet) {
          mergedList.add(MergedTodoItem(
            id: vetItem.id,
            title: vetItem.title,
            description: vetItem.description,
            category: category,
            source: 'vet',
            sourceLabel: vetItem.sourceLabel.isNotEmpty ? vetItem.sourceLabel : "From Veterinarian",
            isDone: vetItem.isResolved,
            date: vetItem.date,
            isSatisfied: false,
          ));
        }

        // Shop items are superseded/satisfied
        for (final shopItem in categoryShop) {
          mergedList.add(MergedTodoItem(
            id: shopItem.id,
            title: shopItem.title,
            description: shopItem.description,
            category: category,
            source: 'shop',
            sourceLabel: shopItem.sourceLabel.isNotEmpty ? shopItem.sourceLabel : "From Shop",
            isDone: true, // Marked satisfied/done
            date: shopItem.date,
            isSatisfied: true,
            supersededByTitle: categoryVet.first.title,
          ));
        }

        // Breed standard items are superseded/satisfied
        for (final stdItem in categoryStandard) {
          mergedList.add(MergedTodoItem(
            id: stdItem.id,
            title: stdItem.title,
            description: stdItem.description,
            category: category,
            source: 'breedStandard',
            sourceLabel: stdItem.sourceLabel.isNotEmpty ? stdItem.sourceLabel : "Standard Care",
            isDone: true, // Marked satisfied/done
            date: stdItem.date,
            isSatisfied: true,
            supersededByTitle: categoryVet.first.title,
          ));
        }
      } else if (categoryShop.isNotEmpty) {
        // Shop items are active
        for (final shopItem in categoryShop) {
          mergedList.add(MergedTodoItem(
            id: shopItem.id,
            title: shopItem.title,
            description: shopItem.description,
            category: category,
            source: 'shop',
            sourceLabel: shopItem.sourceLabel.isNotEmpty ? shopItem.sourceLabel : "From Shop",
            isDone: shopItem.isResolved,
            date: shopItem.date,
            isSatisfied: false,
          ));
        }

        // Breed standard items are superseded/satisfied
        for (final stdItem in categoryStandard) {
          mergedList.add(MergedTodoItem(
            id: stdItem.id,
            title: stdItem.title,
            description: stdItem.description,
            category: category,
            source: 'breedStandard',
            sourceLabel: stdItem.sourceLabel.isNotEmpty ? stdItem.sourceLabel : "Standard Care",
            isDone: true, // Marked satisfied/done
            date: stdItem.date,
            isSatisfied: true,
            supersededByTitle: categoryShop.first.title,
          ));
        }
      } else {
        // Only breed standard items are available in this category
        for (final stdItem in categoryStandard) {
          mergedList.add(MergedTodoItem(
            id: stdItem.id,
            title: stdItem.title,
            description: stdItem.description,
            category: category,
            source: 'breedStandard',
            sourceLabel: stdItem.sourceLabel.isNotEmpty ? stdItem.sourceLabel : "Standard Care",
            isDone: stdItem.isResolved,
            date: stdItem.date,
            isSatisfied: false,
          ));
        }
      }
    }

    // Sort by date, or category, or active first
    mergedList.sort((a, b) {
      if (a.isSatisfied != b.isSatisfied) {
        return a.isSatisfied ? 1 : -1; // Active first
      }
      return b.date.compareTo(a.date); // Newest first
    });

    return mergedList;
  }
}
