import '../models/disease.dart';

enum SeverityLevel { urgent, caution, homecare }

class DiseaseMatch {
  final Disease disease;
  final int score;
  final List<String> matchingSymptoms;

  DiseaseMatch({
    required this.disease,
    required this.score,
    required this.matchingSymptoms,
  });
}

class AdvisoryReport {
  final SeverityLevel overallSeverity;
  final List<DiseaseMatch> topMatches;
  final String generalGuidance;

  AdvisoryReport({
    required this.overallSeverity,
    required this.topMatches,
    required this.generalGuidance,
  });
}

class AdvisoryService {
  /// Evaluates symptoms against the disease dataset and returns a sorted report.
  static AdvisoryReport evaluateSymptoms({
    required List<Disease> diseases,
    required List<String> activeSymptoms,
    required String petSpecies,
    required String ageAnswer,
    required String durationAnswer,
  }) {
    if (activeSymptoms.isEmpty) {
      return AdvisoryReport(
        overallSeverity: SeverityLevel.homecare,
        topMatches: [],
        generalGuidance: 'No symptoms selected. Monitor your pet as usual.',
      );
    }

    final isLongDuration = durationAnswer == '>48 Hours';
    final isYoungPet = ageAnswer == 'Puppy/Kitten (<6 months)';
    List<DiseaseMatch> matches = [];

    for (final disease in diseases) {
      // Hard constraints
      if (disease.targetSpecies != 'all' && disease.targetSpecies != petSpecies.toLowerCase()) {
        continue;
      }
      if (disease.youngOnly && !isYoungPet) continue;
      if (disease.longDurationOnly && !isLongDuration) continue;

      int score = 0;
      List<String> matched = [];

      for (var sym in activeSymptoms) {
        if (disease.requiredSymptoms.contains(sym)) {
          score += 2;
          matched.add(sym);
        } else if (disease.anySymptoms.contains(sym)) {
          score += 1;
          matched.add(sym);
        }
      }

      // Add to matches if at least one symptom matched
      if (score > 0) {
        matches.add(DiseaseMatch(
          disease: disease,
          score: score,
          matchingSymptoms: matched,
        ));
      }
    }

    // Sort by score descending
    matches.sort((a, b) => b.score.compareTo(a.score));

    // Filter to top 3 meaningful matches
    final topMatches = matches.take(3).toList();

    if (topMatches.isEmpty) {
      return AdvisoryReport(
        overallSeverity: SeverityLevel.caution,
        topMatches: [],
        generalGuidance: 'Your pet has registered mild symptoms not strongly matching our core profiles. While not showing clear emergency signals, monitoring and rest are advised. Contact a vet if things decline.',
      );
    }

    // Determine overall severity (highest among top matches)
    SeverityLevel highestSeverity = SeverityLevel.homecare;
    for (var match in topMatches) {
      final level = _parseSeverity(match.disease.level);
      if (level == SeverityLevel.urgent) {
        highestSeverity = SeverityLevel.urgent;
        break; // Can't get higher
      } else if (level == SeverityLevel.caution && highestSeverity == SeverityLevel.homecare) {
        highestSeverity = SeverityLevel.caution;
      }
    }

    return AdvisoryReport(
      overallSeverity: highestSeverity,
      topMatches: topMatches,
      generalGuidance: highestSeverity == SeverityLevel.urgent
          ? 'Urgent attention recommended. Symptoms indicate a high-risk scenario. Please contact a veterinarian.'
          : highestSeverity == SeverityLevel.caution
              ? 'Caution advised. Please monitor closely and consider consulting a veterinarian.'
              : 'Symptoms indicate home care may be sufficient, but monitor for any changes.',
    );
  }

  static SeverityLevel _parseSeverity(String levelStr) {
    switch (levelStr.toLowerCase()) {
      case 'urgent':
        return SeverityLevel.urgent;
      case 'caution':
        return SeverityLevel.caution;
      case 'homecare':
      default:
        return SeverityLevel.homecare;
    }
  }
}
