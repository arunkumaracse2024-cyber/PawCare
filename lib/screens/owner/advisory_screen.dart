import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../../state/encyclopedia_provider.dart';
import '../../../services/advisory_service.dart';

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
            color: Colors.redAccent.withValues(alpha: 0.12),
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
        return _buildGuidelineReport(
            theme,
            isDark,
            Provider.of<AppState>(context),
            Provider.of<EncyclopediaProvider>(context));
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
        RadioGroup<String>(
          groupValue: _durationAnswer,
          onChanged: (val) {
            setState(() {
              _durationAnswer = val;
            });
          },
          child: Column(
            children: durations.map((duration) {
              return RadioListTile<String>(
                title: Text(duration),
                value: duration,
                activeColor: AppTheme.tealSecondary,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Age question
        const Text(
          'What is your pet\'s life stage?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        RadioGroup<String>(
          groupValue: _ageAnswer,
          onChanged: (val) {
            setState(() {
              _ageAnswer = val;
            });
          },
          child: Column(
            children: ages.map((age) {
              return RadioListTile<String>(
                title: Text(age),
                value: age,
                activeColor: AppTheme.tealSecondary,
              );
            }).toList(),
          ),
        ),
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
  Widget _buildGuidelineReport(ThemeData theme, bool isDark, AppState state, EncyclopediaProvider encyclopedia) {
    final activeSymptoms = _symptoms.entries.where((e) => e.value).map((e) => e.key).toList();
    final petSpecies = state.selectedPet?.species ?? 'dog';
    
    final report = AdvisoryService.evaluateSymptoms(
      diseases: encyclopedia.diseases,
      activeSymptoms: activeSymptoms,
      petSpecies: petSpecies,
      ageAnswer: _ageAnswer ?? '',
      durationAnswer: _durationAnswer ?? '',
    );

    // Choose styling color based on severity
    final Color severityColor = report.overallSeverity == SeverityLevel.urgent
        ? Colors.red
        : report.overallSeverity == SeverityLevel.caution
        ? Colors.orange
        : Colors.green;

    final IconData severityIcon = report.overallSeverity == SeverityLevel.urgent
        ? Icons.error_rounded
        : report.overallSeverity == SeverityLevel.caution
        ? Icons.warning_rounded
        : Icons.healing_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Evaluation Results',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        
        // Overall severity banner
        Card(
          color: severityColor.withAlpha((0.15 * 255).toInt()),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: severityColor, width: 1.5),
            borderRadius: BorderRadius.circular(16),
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
                        report.overallSeverity == SeverityLevel.urgent
                            ? 'High Concern'
                            : report.overallSeverity == SeverityLevel.caution
                            ? 'Moderate Concern'
                            : 'Low Concern',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.generalGuidance,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
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

        if (report.topMatches.isNotEmpty) ...[
          const Text(
            'Possible Matches',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...report.topMatches.map((match) {
            final matchColor = match.disease.level == 'urgent'
                ? Colors.red
                : match.disease.level == 'caution'
                ? Colors.orange
                : Colors.green;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.health_and_safety, color: matchColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Symptoms may be consistent with ${match.disease.title}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.disease.guideline,
                      style: const TextStyle(fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    const Text('Actions to consider:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    ...match.disease.actions.map((act) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text(act, style: const TextStyle(fontSize: 12, height: 1.3))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],

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



