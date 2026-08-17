import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_theme.dart';
import '../../../state/app_state.dart';
import '../../../state/encyclopedia_provider.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../models/behaviour_log.dart';
import '../../../models/pet.dart';

class BehaviourScreen extends StatefulWidget {
  const BehaviourScreen({super.key});

  @override
  State<BehaviourScreen> createState() => _BehaviourScreenState();
}

class _BehaviourScreenState extends State<BehaviourScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLogModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.8,
        child: AddBehaviourLogSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.selectedPet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Behaviour Tracker')),
        body: const Center(child: Text('Please select or add a pet first.')),
      );
    }

    final pet = state.selectedPet!;
    final logs = state.behaviourLogs.where((l) => l.petId == pet.id).toList();
    // Sort logs by date ascending for fl_chart
    logs.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Activity & Sleep'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.orangePrimary,
          labelColor: AppTheme.orangeDeep,
          unselectedLabelColor: isDark
              ? Colors.white60
              : Colors.black.withAlpha((0.48 * 255).toInt()),
          tabs: const [
            Tab(icon: Icon(Icons.show_chart_rounded), text: 'Trend Charts'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Log History'),
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Guide'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogModal(context),
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Log Behaviour'),
        backgroundColor: AppTheme.orangePrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChartsTab(logs, isDark),
                _buildHistoryTab(logs, state, isDark),
                _buildGuideTab(state, pet, isDark, Provider.of<EncyclopediaProvider>(context)),
              ],
            ),
    );
  }

  Widget _buildChartsTab(List<BehaviourLog> logs, bool isDark) {
    if (logs.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.insights_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Insufficient Data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Please log behavior for at least 2 days to render sleep vs activity graph comparisons.',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final recentLogs = logs.length > 7 ? logs.sublist(logs.length - 7) : logs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Activity & Energy Trends (1-5 Level)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildActivityChart(recentLogs, isDark),
          const SizedBox(height: 32),
          const Text(
            'Sleep Hours Log (0-24h)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildSleepChart(recentLogs, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActivityChart(List<BehaviourLog> logs, bool isDark) {
    List<FlSpot> spots = [];
    for (int i = 0; i < logs.length; i++) {
      spots.add(FlSpot(i.toDouble(), logs[i].activityLevel.toDouble()));
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 6,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.orangePrimary,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((s) {
                  final log = logs[s.x.toInt()];
                  return LineTooltipItem(
                    'Level: ${s.y.toInt()}\nDate: ${log.date.day}/${log.date.month}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < logs.length) {
                    final date = logs[idx].date;
                    return Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.orangePrimary,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.orangePrimary.withAlpha((0.12 * 255).toInt()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart(List<BehaviourLog> logs, bool isDark) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < logs.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: logs[i].sleepHours,
              color: AppTheme.tealSecondary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: BarChart(
        BarChartData(
          maxY: 24,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 6,
                reservedSize: 28,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < logs.length) {
                    final date = logs[idx].date;
                    return Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          barGroups: barGroups,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppTheme.tealSecondary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final log = logs[group.x];
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)} hrs\nDate: ${log.date.day}/${log.date.month}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(
    List<BehaviourLog> logs,
    AppState state,
    bool isDark,
  ) {
    if (logs.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history_rounded,
        message: 'No logs saved yet. Create your first behaviour log!',
      );
    }

    // Show newest first
    final reversedLogs = logs.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reversedLogs.length,
      itemBuilder: (context, index) {
        final log = reversedLogs[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Log: ${log.date.day}/${log.date.month}/${log.date.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        state.deleteBehaviourLog(log.id);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHistoryTag(
                      'Activity',
                      '${log.activityLevel}/5',
                      Icons.directions_run_rounded,
                      Colors.orange,
                    ),
                    _buildHistoryTag(
                      'Sleep',
                      '${log.sleepHours} hrs',
                      Icons.bedtime_rounded,
                      Colors.teal,
                    ),
                    _buildHistoryTag(
                      'Appetite',
                      log.eatingStatus,
                      Icons.restaurant_rounded,
                      Colors.purple,
                    ),
                  ],
                ),
                if (log.notes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF333333)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      log.notes,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTag(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGuideTab(AppState state, Pet pet, bool isDark, EncyclopediaProvider encyclopedia) {
    final traits = encyclopedia.behaviours.where((b) => b.species == pet.species.toLowerCase()).toList();
    if (traits.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.menu_book_rounded,
          message: 'No behaviour guide available for ${pet.species}.',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: traits.length,
      itemBuilder: (context, index) {
        final t = traits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.orangePrimary.withAlpha((0.2 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.category,
                        style: const TextStyle(
                          color: AppTheme.orangePrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.traitName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddBehaviourLogSheet extends StatefulWidget {
  const AddBehaviourLogSheet({super.key});

  @override
  State<AddBehaviourLogSheet> createState() => _AddBehaviourLogSheetState();
}

class _AddBehaviourLogSheetState extends State<AddBehaviourLogSheet> {
  final _formKey = GlobalKey<FormState>();
  double _activityLevel = 3.0; // 1-5
  double _sleepHours = 8.0; // 0-24
  String _eatingStatus = 'Normal'; // Poor, Normal, Great
  final TextEditingController _notesController = TextEditingController();

  final List<String> _eatStatuses = ['Poor', 'Normal', 'Great'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log Daily Behaviour',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 24),

            // Activity Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Level',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${_activityLevel.toInt()}/5',
                  style: const TextStyle(
                    color: AppTheme.orangeDeep,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _activityLevel,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              label: '${_activityLevel.toInt()}',
              onChanged: (val) {
                setState(() {
                  _activityLevel = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sleep Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sleep Duration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${_sleepHours.toStringAsFixed(1)} hrs',
                  style: const TextStyle(
                    color: AppTheme.tealDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _sleepHours,
              min: 0.0,
              max: 24.0,
              divisions: 48,
              label: '${_sleepHours.toStringAsFixed(1)} hrs',
              onChanged: (val) {
                setState(() {
                  _sleepHours = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Feeding Status Segmented/Select Buttons
            const Text(
              'Appetite & Feeding',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: _eatStatuses.map((status) {
                final isSelected = _eatingStatus == status;
                final chipColor = status == 'Poor'
                    ? Colors.redAccent
                    : status == 'Normal'
                    ? AppTheme.tealSecondary
                    : Colors.green;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _eatingStatus = status),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? chipColor
                            : (isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? chipColor
                              : (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white60
                                    : Colors.black.withAlpha((0.8 * 255).toInt())),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g. slight cough today, or did not finish kibble',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              maxLines: 2,
            ),
            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                final state = Provider.of<AppState>(context, listen: false);
                await state.addBehaviourLog(
                  activityLevel: _activityLevel.toInt(),
                  sleepHours: _sleepHours,
                  eatingStatus: _eatingStatus,
                  notes: _notesController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Log'),
            ),
          ],
        ),
      ),
    );
  }
}



