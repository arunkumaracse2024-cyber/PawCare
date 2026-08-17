import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_theme.dart';
import '../../../state/app_state.dart';
import '../../../models/weight_record.dart';

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  void _showAddEditSheet(BuildContext context, {WeightRecord? record}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.6,
        child: _AddEditWeightSheet(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pet = state.selectedPet;

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weight History')),
        body: const Center(child: Text('No pet selected.')),
      );
    }

    final history = List<WeightRecord>.from(state.weightHistory);
    history.sort((a, b) => b.date.compareTo(a.date)); // descending

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Weight'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(context),
        icon: const Icon(Icons.monitor_weight_outlined),
        label: const Text('Add Weight'),
        backgroundColor: AppTheme.tealSecondary,
      ),
      body: Column(
        children: [
          // Chart Section
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF252525) : Colors.amber.withAlpha((0.08 * 255).toInt()),
            height: 250,
            child: history.isEmpty
                ? const Center(child: Text('No weight data available to chart.'))
                : _buildChart(history, isDark),
          ),

          const Divider(height: 1),

          // History List
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Text(
                      'No entries yet.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final r = history[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.tealSecondary.withAlpha((0.15 * 255).toInt()),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.scale, color: AppTheme.tealSecondary, size: 20),
                          ),
                          title: Text(
                            '${r.weight.toStringAsFixed(2)} kg',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${r.date.day}/${r.date.month}/${r.date.year}',
                                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                              ),
                              if (r.notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  r.notes,
                                  style: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                onPressed: () => _showAddEditSheet(context, record: r),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Delete Entry?'),
                                      content: const Text('Are you sure you want to delete this weight record?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () => Navigator.pop(c, true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    state.deleteWeightRecord(r.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<WeightRecord> history, bool isDark) {
    if (history.length == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, size: 48, color: AppTheme.tealSecondary),
            const SizedBox(height: 12),
            Text(
              'Add more entries to see trends.',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
            ),
          ],
        ),
      );
    }

    // Sort ascending for chart
    final chartData = List<WeightRecord>.from(history)..sort((a, b) => a.date.compareTo(b.date));
    
    // Find min and max values to scale the Y axis properly
    double minWeight = chartData.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    double maxWeight = chartData.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    double yMin = (minWeight - 1).clamp(0, double.infinity);
    double yMax = maxWeight + 1;

    final spots = chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    return LineChart(
      LineChartData(
        minY: yMin,
        maxY: yMax,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  final date = chartData[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.tealSecondary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.tealSecondary.withAlpha((0.2 * 255).toInt()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEditWeightSheet extends StatefulWidget {
  final WeightRecord? record;
  const _AddEditWeightSheet({this.record});

  @override
  State<_AddEditWeightSheet> createState() => _AddEditWeightSheetState();
}

class _AddEditWeightSheetState extends State<_AddEditWeightSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.record?.weight.toString() ?? '');
    _notesController = TextEditingController(text: widget.record?.notes ?? '');
    _selectedDate = widget.record?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
              Text(
                widget.record == null ? 'Record Weight' : 'Edit Weight',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a weight';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (state.selectedPet == null) return;
                  
                  final weight = double.parse(_weightController.text.trim());
                  
                  if (widget.record == null) {
                    final newRecord = WeightRecord(
                      id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
                      petId: state.selectedPet!.id,
                      weight: weight,
                      date: _selectedDate,
                      notes: _notesController.text.trim(),
                    );
                    await state.addWeightRecord(newRecord);
                  } else {
                    final updatedRecord = widget.record!.copyWith(
                      weight: weight,
                      date: _selectedDate,
                      notes: _notesController.text.trim(),
                    );
                    await state.updateWeightRecord(updatedRecord);
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.tealSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.record == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
