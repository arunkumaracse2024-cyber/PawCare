import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../models/pet_disease.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  int _currentStep = 0;

  // Selected symptoms Checklist
  final Map<String, bool> _symptoms = {};

  // Questionnaire responses
  String? _durationAnswer; // '<24 Hours', '24-48 Hours', '>48 Hours'
  String? _ageAnswer; // 'Puppy/Kitten (<6 months)', 'Adult'

  List<String> _allAvailableSymptoms = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = Provider.of<AppState>(context);
      if (!state.isDatasetLoading) {
        final Set<String> uniqueSymptoms = {};
        for (var disease in state.diseases) {
          for (var s in disease.symptoms) {
            uniqueSymptoms.add(s);
          }
        }
        
        // Add fallback symptoms if dataset is empty
        if (uniqueSymptoms.isEmpty) {
          uniqueSymptoms.addAll([
            'Fever / Very Warm Ears',
            'Slight Coughing or Sneezing',
            'Frequent Vomiting or Diarrhea',
            'Severe Lethargy / Low Energy',
            'Loss of Appetite / Refusing Water',
            'Minor Skin Scratch or Redness'
          ]);
        }

        _allAvailableSymptoms = uniqueSymptoms.toList()..sort();
        for (var s in _allAvailableSymptoms) {
          _symptoms[s] = false;
        }
        _initialized = true;
      }
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _symptoms.updateAll((key, value) => false);
      _durationAnswer = null;
      _ageAnswer = null;
    });
  }

  // Rule-based reasoning engine using Dataset
  AdvisoryResult _evaluateSymptoms(List<PetDisease> allDiseases) {
    final selectedSymptoms = _symptoms.entries.where((e) => e.value).map((e) => e.key).toList();
    
    if (selectedSymptoms.isEmpty) {
      return AdvisoryResult(
        level: SeverityLevel.homecare,
        title: 'No Symptoms Selected',
        guideline: 'Please select symptoms to get relevant information.',
        actions: ['Monitor your pet.'],
        associatedConditions: [],
      );
    }

    // Match conditions based on selected symptoms
    final List<PetDisease> matchedConditions = [];
    for (var disease in allDiseases) {
      bool matches = false;
      for (var s in selectedSymptoms) {
        if (disease.symptoms.contains(s)) {
          matches = true;
          break;
        }
      }
      if (matches) matchedConditions.add(disease);
    }

    // Evaluate severity based on matched conditions and context
    SeverityLevel overallSeverity = SeverityLevel.homecare;
    for (var disease in matchedConditions) {
      if (disease.severity == 'high') {
        overallSeverity = SeverityLevel.urgent;
        break;
      } else if (disease.severity == 'moderate' && overallSeverity != SeverityLevel.urgent) {
        overallSeverity = SeverityLevel.caution;
      }
    }

    final isLongDuration = _durationAnswer == '>48 Hours';
    final isYoungPet = _ageAnswer == 'Puppy/Kitten (<6 months)';

    if (isLongDuration || isYoungPet) {
      if (overallSeverity == SeverityLevel.homecare) overallSeverity = SeverityLevel.caution;
      else if (overallSeverity == SeverityLevel.caution) overallSeverity = SeverityLevel.urgent;
    }

    // Construct response
    String title = '';
    String guideline = '';
    List<String> actions = [];

    if (overallSeverity == SeverityLevel.urgent) {
      title = 'Urgent Veterinary Attention Required';
      guideline = 'These symptoms may be associated with several conditions, some of which are potentially severe (e.g., ${matchedConditions.take(2).map((e) => e.diseaseName).join(', ')}). A veterinarian should evaluate your pet for an accurate diagnosis.';
      actions = [
        'Call your local veterinary hospital immediately.',
        'Do not wait for symptoms to pass.',
        'Keep your pet warm and calm during transport.',
      ];
    } else if (overallSeverity == SeverityLevel.caution) {
      title = 'Veterinary Checkup Recommended';
      guideline = 'These symptoms may be associated with several conditions. A veterinarian should evaluate your pet for an accurate diagnosis.';
      actions = [
        'Book an appointment with your vet within the next 24-48 hours.',
        'Ensure your pet has quiet, comfortable isolation space.',
        'Track symptoms closely and call vet if things decline.',
      ];
    } else {
      title = 'General Monitoring Suggested';
      guideline = 'Your pet has registered mild symptoms. While not showing immediate emergency signals, monitoring is advised. A veterinarian should evaluate your pet if symptoms worsen or persist.';
      actions = [
        'Place a bowl of clean water nearby and monitor their consumption.',
        'Ensure they rest.',
        'If symptoms persist beyond 24-48 hours, contact a vet.',
      ];
    }

    // Add specific warning signs from conditions if available
    for (var disease in matchedConditions) {
      if (disease.whenToSeeVet.isNotEmpty && !actions.contains(disease.whenToSeeVet)) {
        actions.add('Warning sign: ${disease.whenToSeeVet}');
      }
    }

    return AdvisoryResult(
      level: overallSeverity,
      title: title,
      guideline: guideline,
      actions: actions.take(6).toList(), // Limit to 6 actions for readability
      associatedConditions: matchedConditions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.isDatasetLoading || !_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Symptom Advisor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Advisor'),
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _reset,
              tooltip: 'Reset Wizard',
            ),
        ],
      ),
      body: Column(
        children: [
          // DISCLAIMER BANNER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.redAccent.withOpacity(0.12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'DISCLAIMER: This diagnostic wizard is a static, rule-based tool for informational purposes. It is NOT AI and does NOT replace a veterinary diagnostic checkup. Dial emergency vets if distressed.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.redAccent.shade100
                          : Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // STEP PROGRESS INDICATOR
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              children: List.generate(3, (index) {
                final isPassed = _currentStep >= index;
                final isCurrent = _currentStep == index;
                return Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isPassed
                            ? AppTheme.tealSecondary
                            : Colors.grey.shade400,
                        child: isPassed && !isCurrent
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      if (index < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: _currentStep > index
                                ? AppTheme.tealSecondary
                                : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: _buildWizardStep(theme, isDark, state.diseases),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardStep(ThemeData theme, bool isDark, List<PetDisease> allDiseases) {
    switch (_currentStep) {
      case 0:
        return _buildSymptomChecklist(isDark);
      case 1:
        return _buildQuestionnaire(isDark);
      case 2:
        return _buildGuidelineReport(theme, isDark, allDiseases);
      default:
        return const SizedBox();
    }
  }

  // --- STEP 1: SYMPTOMS CHECKLIST ---
  Widget _buildSymptomChecklist(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 1: Select Active Symptoms',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Identify what physical signals or behaviors your pet is displaying.',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        const SizedBox(height: 20),
        ..._allAvailableSymptoms.map((symptom) {
          final isSelected = _symptoms[symptom] ?? false;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.orangePrimary
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                width: 1.5,
              ),
            ),
            child: CheckboxListTile(
              title: Text(
                symptom,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              value: isSelected,
              activeColor: AppTheme.orangePrimary,
              onChanged: (val) {
                setState(() {
                  _symptoms[symptom] = val ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStep = 1;
            });
          },
          child: const Text('Proceed to Questions'),
        ),
      ],
    );
  }

  // --- STEP 2: DURATION & AGE QUESTIONS ---
  Widget _buildQuestionnaire(bool isDark) {
    final durations = ['<24 Hours', '24-48 Hours', '>48 Hours'];
    final ages = [
      'Puppy/Kitten (<6 months)',
      'Adult (1-8 years)',
      'Senior (9+ years)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 2: Additional Context',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'A few quick questions to narrow down the severity of the symptoms.',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        const SizedBox(height: 24),

        // Duration question
        const Text(
          'How long has your pet been showing these symptoms?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        ...durations.map((duration) {
          return RadioListTile<String>(
            title: Text(duration),
            value: duration,
            groupValue: _durationAnswer,
            activeColor: AppTheme.tealSecondary,
            onChanged: (val) {
              setState(() {
                _durationAnswer = val;
              });
            },
          );
        }),
        const SizedBox(height: 24),

        // Age question
        const Text(
          'What is your pet\'s life stage?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        ...ages.map((age) {
          return RadioListTile<String>(
            title: Text(age),
            value: age,
            groupValue: _ageAnswer,
            activeColor: AppTheme.tealSecondary,
            onChanged: (val) {
              setState(() {
                _ageAnswer = val;
              });
            },
          );
        }),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep = 0);
                },
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _durationAnswer != null && _ageAnswer != null
                    ? () => setState(() => _currentStep = 2)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orangePrimary,
                ),
                child: const Text('Generate Report'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 3: RESULTS SUMMARY REPORT ---
  Widget _buildGuidelineReport(ThemeData theme, bool isDark, List<PetDisease> allDiseases) {
    final result = _evaluateSymptoms(allDiseases);

    // Choose styling color based on severity
    final Color severityColor = result.level == SeverityLevel.urgent
        ? Colors.red
        : result.level == SeverityLevel.caution
        ? Colors.orange
        : Colors.green;

    final IconData severityIcon = result.level == SeverityLevel.urgent
        ? Icons.error_rounded
        : result.level == SeverityLevel.caution
        ? Icons.warning_rounded
        : Icons.healing_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 3: Advisory Recommendations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Severity Banner
        Card(
          color: severityColor.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: severityColor.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(severityIcon, color: severityColor, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: severityColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${result.level.name.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Result Guideline
        const Text(
          'Assessment Narrative',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              result.guideline,
              style: const TextStyle(fontSize: 14, height: 1.45),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Associated Conditions List (Educational)
        if (result.associatedConditions.isNotEmpty) ...[
          const Text(
            'Possible Associated Conditions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ...result.associatedConditions.map((condition) {
            return Card(
              child: ExpansionTile(
                title: Text(condition.diseaseName, style: const TextStyle(fontWeight: FontWeight.w600)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(condition.description, style: const TextStyle(height: 1.4)),
                        const SizedBox(height: 12),
                        const Text('Possible Causes:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(condition.possibleCauses.join(', ')),
                        const SizedBox(height: 12),
                        const Text('Prevention:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(condition.prevention.join(', ')),
                      ],
                    ),
                  )
                ]
              )
            );
          }),
          const SizedBox(height: 24),
        ],

        // Action Steps Items
        const Text(
          'Suggested Action Plan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...result.actions.map((act) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_right_rounded,
                  color: AppTheme.tealSecondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    act,
                    style: const TextStyle(fontSize: 14, height: 1.3),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 36),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep = 1);
                },
                child: const Text('Back to Questions'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _reset,
                child: const Text('Restart Checker'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum SeverityLevel { urgent, caution, homecare }

class AdvisoryResult {
  final SeverityLevel level;
  final String title;
  final String guideline;
  final List<String> actions;
  final List<PetDisease> associatedConditions;

  AdvisoryResult({
    required this.level,
    required this.title,
    required this.guideline,
    required this.actions,
    required this.associatedConditions,
  });
}
