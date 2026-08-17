import 'package:flutter_test/flutter_test.dart';
import 'package:petpaw/models/disease.dart';
import 'package:petpaw/services/advisory_service.dart';

void main() {
  group('AdvisoryService.evaluateSymptoms', () {
    final List<Disease> testDiseases = [
      Disease(
        id: 'd1',
        targetSpecies: 'all',
        requiredSymptoms: ['Vomiting', 'Lethargy'],
        anySymptoms: [],
        youngOnly: false,
        longDurationOnly: false,
        level: 'urgent',
        title: 'Emergency Condition',
        guideline: 'Urgent guideline',
        actions: ['Action 1'],
      ),
      Disease(
        id: 'd2',
        targetSpecies: 'dog',
        requiredSymptoms: ['Cough'],
        anySymptoms: ['Fever'],
        youngOnly: false,
        longDurationOnly: false,
        level: 'caution',
        title: 'Dog Flu',
        guideline: 'Caution guideline',
        actions: ['Action 1'],
      ),
      Disease(
        id: 'd3',
        targetSpecies: 'all',
        requiredSymptoms: [],
        anySymptoms: ['Scratch'],
        youngOnly: false,
        longDurationOnly: false,
        level: 'homecare',
        title: 'Minor Scratch',
        guideline: 'Homecare guideline',
        actions: ['Action 1'],
      ),
      Disease(
        id: 'd4',
        targetSpecies: 'cat',
        requiredSymptoms: ['Vomiting'],
        anySymptoms: ['Lethargy'],
        youngOnly: true,
        longDurationOnly: false,
        level: 'urgent',
        title: 'Kitten Emergency',
        guideline: 'Urgent kitten guideline',
        actions: ['Action 1'],
      ),
    ];

    test('No symptom selection returns homecare severity with no top matches', () {
      final report = AdvisoryService.evaluateSymptoms(
        diseases: testDiseases,
        activeSymptoms: [],
        petSpecies: 'dog',
        ageAnswer: 'Adult',
        durationAnswer: '<24 Hours',
      );

      expect(report.overallSeverity, SeverityLevel.homecare);
      expect(report.topMatches.isEmpty, true);
      expect(report.generalGuidance, contains('No symptoms selected'));
    });

    test('Single weak match returns correct match with caution severity (if caution is not reached, wait, scratch is homecare)', () {
      final report = AdvisoryService.evaluateSymptoms(
        diseases: testDiseases,
        activeSymptoms: ['Scratch'],
        petSpecies: 'dog',
        ageAnswer: 'Adult',
        durationAnswer: '<24 Hours',
      );

      expect(report.overallSeverity, SeverityLevel.homecare);
      expect(report.topMatches.length, 1);
      expect(report.topMatches.first.disease.id, 'd3');
      expect(report.topMatches.first.score, 1); // 1 optional symptom matched
    });

    test('Strong match with required symptoms scores higher', () {
      final report = AdvisoryService.evaluateSymptoms(
        diseases: testDiseases,
        activeSymptoms: ['Vomiting', 'Lethargy'],
        petSpecies: 'dog',
        ageAnswer: 'Adult',
        durationAnswer: '<24 Hours',
      );

      expect(report.overallSeverity, SeverityLevel.urgent);
      expect(report.topMatches.isNotEmpty, true);
      expect(report.topMatches.first.disease.id, 'd1');
      expect(report.topMatches.first.score, 4); // 2 required symptoms * 2
    });

    test('Multiple matches are sorted by score descending', () {
      final report = AdvisoryService.evaluateSymptoms(
        diseases: testDiseases,
        activeSymptoms: ['Cough', 'Fever', 'Scratch'],
        petSpecies: 'dog',
        ageAnswer: 'Adult',
        durationAnswer: '<24 Hours',
      );

      // Dog Flu matches Cough (required +2) and Fever (any +1) = 3
      // Minor Scratch matches Scratch (any +1) = 1
      expect(report.topMatches.length, 2);
      expect(report.topMatches[0].disease.id, 'd2');
      expect(report.topMatches[1].disease.id, 'd3');
      expect(report.overallSeverity, SeverityLevel.caution);
    });

    test('Species mismatch prevents disease from matching', () {
      final report = AdvisoryService.evaluateSymptoms(
        diseases: testDiseases,
        activeSymptoms: ['Cough', 'Fever'],
        petSpecies: 'cat', // d2 is dog only
        ageAnswer: 'Adult',
        durationAnswer: '<24 Hours',
      );

      // No matches because Dog Flu is dog only, others don't match symptoms
      expect(report.topMatches.isEmpty, true);
      expect(report.overallSeverity, SeverityLevel.caution); // fallback empty level
    });
    
    test('High severity case returns urgent and suggests vet', () {
      final report = AdvisoryService.evaluateSymptoms(
        diseases: testDiseases,
        activeSymptoms: ['Vomiting', 'Lethargy'],
        petSpecies: 'cat',
        ageAnswer: 'Puppy/Kitten (<6 months)',
        durationAnswer: '<24 Hours',
      );

      // Matches both d1 (score 4) and d4 (score 3)
      expect(report.topMatches.length, 2);
      expect(report.overallSeverity, SeverityLevel.urgent);
      expect(report.generalGuidance, contains('veterinarian'));
    });

    test('No dataset available (empty list) does not crash and returns fallback', () {
      final report = AdvisoryService.evaluateSymptoms(
        diseases: [],
        activeSymptoms: ['Cough'],
        petSpecies: 'dog',
        ageAnswer: 'Adult',
        durationAnswer: '<24 Hours',
      );

      expect(report.topMatches.isEmpty, true);
      expect(report.overallSeverity, SeverityLevel.caution);
    });
  });
}
