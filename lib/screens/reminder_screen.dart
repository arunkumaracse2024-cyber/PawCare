import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../models/reminder.dart';
import '../../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _notifier = NotificationService();

  @override
  void initState() {
    super.initState();
    _notifier.initialize();
  }

  void _showAddReminderDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.75,
        child: AddReminderSheet(),
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
        appBar: AppBar(title: const Text('Reminders')),
        body: const Center(child: Text('Please select or add a pet first.')),
      );
    }

    final activeReminders = state.reminders.where((r) => !r.isDone).toList();
    final completedReminders = state.reminders.where((r) => r.isDone).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${pet.name}\'s Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(context),
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text('Add Smart Reminder'),
        backgroundColor: AppTheme.orangePrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.reminders.isEmpty
          ? _buildEmptyState(isDark)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (activeReminders.isNotEmpty) ...[
                  const Text(
                    'Upcoming Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ...activeReminders.map(
                    (r) => _buildReminderTile(context, state, r, isDark),
                  ),
                  const SizedBox(height: 24),
                ],
                if (completedReminders.isNotEmpty) ...[
                  const Text(
                    'Completed Tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...completedReminders.map(
                    (r) => _buildReminderTile(context, state, r, isDark),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.tealSecondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: AppTheme.tealSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Reminders Found!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to schedule vaccines, medical prescriptions, or daily grooming reminders.',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    AppState state,
    PetReminder r,
    bool isDark,
  ) {
    final isOverdue = !r.isDone && r.dateTime.isBefore(DateTime.now());

    final typeIcon = r.type.toLowerCase() == 'vaccine'
        ? Icons.vaccines_rounded
        : r.type.toLowerCase() == 'medicine'
        ? Icons.medication_rounded
        : r.type.toLowerCase() == 'grooming'
        ? Icons.content_cut_rounded
        : Icons.restaurant_rounded;

    final baseColor = r.isDone
        ? Colors.grey
        : isOverdue
        ? Colors.redAccent
        : AppTheme.tealSecondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: r.isDone ? Colors.transparent : baseColor.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: baseColor.withOpacity(0.12),
          child: Icon(typeIcon, color: baseColor),
        ),
        title: Text(
          r.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: r.isDone ? TextDecoration.lineThrough : null,
            color: r.isDone
                ? (isDark ? Colors.white30 : Colors.black38)
                : (isDark ? Colors.white : Colors.black.withOpacity(0.85)),
          ),
        ),
        subtitle: Text(
          '${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year} - '
          '${r.dateTime.hour.toString().padLeft(2, '0')}:${r.dateTime.minute.toString().padLeft(2, '0')} '
          '(${r.repeatOption})${isOverdue ? " - Overdue!" : ""}',
          style: TextStyle(
            fontSize: 12,
            color: r.isDone
                ? Colors.grey
                : isOverdue
                ? Colors.redAccent
                : (isDark ? Colors.white60 : Colors.black54),
            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: r.isDone,
              activeColor: AppTheme.tealSecondary,
              onChanged: (val) {
                if (val != null) {
                  state.toggleReminderDone(r.id, val);
                  if (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked task as completed.'),
                        backgroundColor: AppTheme.tealSecondary,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Colors.redAccent,
              ),
              onPressed: () {
                state.deleteReminder(r.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _type = 'Vaccine';
  DateTime _selectedDate = DateTime.now().add(const Duration(minutes: 10));
  String _repeatOption = 'None';

  final List<String> _types = ['Vaccine', 'Medicine', 'Grooming', 'Feeding'];
  final List<String> _repeats = ['None', 'Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
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
              'Add Smart Reminder',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 20),

            // Title field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (v) => _title = v?.trim() ?? '',
            ),
            const SizedBox(height: 16),

            // Picker Category Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF444444)
                                : const Color(0xFFEBE3D5),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _type,
                            isExpanded: true,
                            onChanged: (v) {
                              if (v != null) setState(() => _type = v);
                            },
                            items: _types
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recurrence',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF444444)
                                : const Color(0xFFEBE3D5),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _repeatOption,
                            isExpanded: true,
                            onChanged: (v) {
                              if (v != null) setState(() => _repeatOption = v);
                            },
                            items: _repeats
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date / Time Toggles
            const Text(
              'Schedule Date & Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF444444)
                        : const Color(0xFFEBE3D5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppTheme.tealSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at '
                      '${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Demo shortcuts helper
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('+1 Min (Demo)'),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now().add(
                        const Duration(minutes: 1),
                      );
                    });
                  },
                ),
                ActionChip(
                  label: const Text('+1 Day'),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now().add(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
              ],
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();

                final state = Provider.of<AppState>(context, listen: false);
                await state.addReminder(
                  title: _title,
                  type: _type,
                  dateTime: _selectedDate,
                  repeatOption: _repeatOption,
                );

                // Schedule mock push trigger
                final reminderId = DateTime.now().millisecondsSinceEpoch;
                await NotificationService().scheduleNotification(
                  id: reminderId,
                  title: '${state.selectedPet!.name}\'s $_type Reminder',
                  body: _title,
                  scheduledDate: _selectedDate,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Schedule Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
