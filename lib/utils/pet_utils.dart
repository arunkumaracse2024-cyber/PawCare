import '../models/growth_stage.dart';

class PetUtils {
  // Species Bounds Constants (in kg)
  static double getMinAge(String species) => 0.0;
  
  static double getMaxAge(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return 25.0;
      case 'bird':
        return 80.0;
      case 'dog':
      default:
        return 20.0;
    }
  }

  static double getMinWeightKg(String species) {
    switch (species.toLowerCase()) {
      case 'bird':
        return 0.01;
      case 'cat':
      case 'dog':
      default:
        return 0.5;
    }
  }

  static double getMaxWeightKg(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return 12.0;
      case 'bird':
        return 2.0;
      case 'dog':
      default:
        return 90.0;
    }
  }

  // Weight conversion helpers
  static double kgToLb(double kg) => double.parse((kg * 2.20462).toStringAsFixed(2));
  static double lbToKg(double lb) => double.parse((lb / 2.20462).toStringAsFixed(2));

  static GrowthStage? getGrowthStage(List<GrowthStage> stages, String species, double ageYears) {
    final speciesStages = stages.where((s) => s.species == species.toLowerCase()).toList();
    if (speciesStages.isEmpty) return null;

    // Simple parser for standard format: "0-12 months", "1-7 years", "7+ years"
    for (var stage in speciesStages) {
      final range = stage.ageRange.toLowerCase();
      if (range.contains('months')) {
        // e.g. 0-12 months => < 1.0 years
        if (ageYears <= 1.0) return stage;
      } else if (range.contains('years')) {
        if (range.contains('+')) {
          // e.g. "7+ years"
          final parts = range.split('+');
          final min = double.tryParse(parts[0].trim()) ?? 0.0;
          if (ageYears >= min) return stage;
        } else if (range.contains('-')) {
          // e.g. "1-7 years"
          final parts = range.replaceAll('years', '').split('-');
          if (parts.length == 2) {
             final min = double.tryParse(parts[0].trim()) ?? 0.0;
             final max = double.tryParse(parts[1].trim()) ?? 99.0;
             if (ageYears >= min && ageYears < max) return stage;
          }
        }
      }
    }
    // Fallback to last stage if nothing matches and we have stages
    return speciesStages.last;
  }
}
