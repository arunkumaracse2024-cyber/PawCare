import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  int _currentStep = 0;

  // Selected symptoms Checklist
  final Map<String, bool> _symptoms = {
    'Fever / Very Warm Ears': false,
    'Slight Coughing or Sneezing': false,
    'Frequent Vomiting or Diarrhea': false,
    'Severe Lethargy / Low Energy': false,
    'Loss of Appetite / Refusing Water': false,
    'Minor Skin Scratch or Redness': false,
  };

  // Questionnaire responses
  String? _durationAnswer; // '<24 Hours', '24-48 Hours', '>48 Hours'
  String? _ageAnswer; // 'Puppy/Kitten (<6 months)', 'Adult'

  void _reset() {
    setState(() {
      _currentStep = 0;
      _symptoms.updateAll((key, value) => false);
      _durationAnswer = null;
      _ageAnswer = null;
    });
  }

  // Simple offline rule-based reasoning engine
  AdvisoryResult _evaluateSymptoms() {
    final hasVomiting = _symptoms['Frequent Vomiting or Diarrhea'] ?? false;
    final hasLethargy = _symptoms['Severe Lethargy / Low Energy'] ?? false;
    final hasAppetiteLoss =
        _symptoms['Loss of Appetite / Refusing Water'] ?? false;
    final hasFever = _symptoms['Fever / Very Warm Ears'] ?? false;
    final hasCough = _symptoms['Slight Coughing or Sneezing'] ?? false;
    final hasScratch = _symptoms['Minor Skin Scratch or Redness'] ?? false;

    final isLongDuration = _durationAnswer == '>48 Hours';
    final isYoungPet = _ageAnswer == 'Puppy/Kitten (<6 months)';

    // Rule 1: Emergency Red Flag Combined symptoms
    if (hasVomiting && hasLethargy) {
      return AdvisoryResult(
        level: SeverityLevel.urgent,
        title: 'Urgent Veterinary Attention Required',
        guideline:
            'Vomiting combined with severe lethargy is a red-flag condition representing possible dehydration, obstruction, or systemic infection. Do not wait for symptoms to pass.',
        actions: [
          'Call your local veterinary hospital immediately.',
          'Do not offer heavy food; keep small amounts of fresh water close.',
          'Keep your pet warm and calm during transport.',
        ],
      );
    }

    // Rule 2: Vulnerable age check
    if (isYoungPet && (hasVomiting || hasLethargy || hasAppetiteLoss)) {
      return AdvisoryResult(
        level: SeverityLevel.urgent,
        title: 'Urgent Checkup for Young Pet',
        guideline:
            'Puppies and kittens under 6 months have low safety reserves. Dehydration or loss of glucose from not eating can become critical within hours.',
        actions: [
          'Contact your veterinarian or emergency clinic for consultation.',
          'Keep your pet dry and warm.',
          'Monitor gums: they should be moist and pink, not dry or pale.',
        ],
      );
    }

    // Rule 3: Prolonged general symptoms
    if (isLongDuration && (hasFever || hasCough || hasAppetiteLoss)) {
      return AdvisoryResult(
        level: SeverityLevel.caution,
        title: 'Veterinary Checkup Recommended',
        guideline:
            'General symptoms lasting for more than 48 hours require physical inspection. Safe self-recovery is unlikely without diagnostic assistance.',
        actions: [
          'Book an appointment with your vet within the next 24 hours.',
          'Ensure your pet has quiet, comfortable isolation space.',
          'Keep details of when they last ate or passed urine/stool.',
        ],
      );
    }

    // Rule 4: Scratch home care guidelines
    if (hasScratch && !hasVomiting && !hasLethargy) {
      return AdvisoryResult(
        level: SeverityLevel.homecare,
        title: 'Home Care for Minor Scratches',
        guideline:
            'A minor scratch or superficial redness with normal appetite and energy can usually be monitored and treated at home.',
        actions: [
          'Clean the area gently using sterile saline or diluted pet-safe soap.',
          'Apply an e-collar (cone) to prevent your pet from licking the wound.',
          'Keep dry and inspect twice daily for signs of swelling or pus.',
        ],
      );
    }

    // Rule 5: Slight cold / respiratory
    if (hasCough && !hasVomiting) {
      return AdvisoryResult(
        level: SeverityLevel.homecare,
        title: 'Mild Respiratory Comfort',
        guideline:
            'Slight coughing or sneezing with normal energy could represent mild kennel cough or seasonal dust allergy.',
        actions: [
          'Keep the pet comfortable, warm, and away from dry draft currents.',
          'Isolate from other household pets to prevent contagions.',
          'If coughing becomes deep/honking, consult your vet.',
        ],
      );
    }

    // Default Case
    return AdvisoryResult(
      level: SeverityLevel.caution,
      title: 'General Monitoring Suggested',
      guideline:
          'Your pet has registered mild symptoms. While not showing emergency signals, monitoring and rest are advised.',
      actions: [
        'Place a bowl of clean water nearby and monitor their consumption.',
        'Refrain from feeding table scraps or switching dog/cat food today.',
        'Track symptoms for the next 24-48 hours. Call vet if things decline.',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    'DISCLAIMER: This diagnostic wizard is a static, rule-based decision tree for informational purposes. It is NOT AI and does NOT replace a veterinary diagnostic checkup. Dial emergency vets if distressed.',
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
              child: _buildWizardStep(theme, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardStep(ThemeData theme, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildSymptomChecklist(isDark);
      case 1:
        return _buildQuestionnaire(isDark);
      case 2:
        return _buildGuidelineReport(theme, isDark);
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
        ..._symptoms.keys.map((symptom) {
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
            // Validate at least one symptom selected is nice, but empty is allowed (general advice)
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
  Widget _buildGuidelineReport(ThemeData theme, bool isDark) {
    final result = _evaluateSymptoms();

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

  AdvisoryResult({
    required this.level,
    required this.title,
    required this.guideline,
    required this.actions,
  });
}
