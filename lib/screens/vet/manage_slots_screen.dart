import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class ManageSlotsScreen extends StatefulWidget {
  const ManageSlotsScreen({super.key});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _startTime = "09:00";
  String _endTime = "09:30";
  bool _isLoading = false;

  final List<String> _timePresets = [
    "09:00 - 09:30",
    "09:30 - 10:00",
    "10:00 - 10:30",
    "10:30 - 11:00",
    "11:00 - 11:30",
    "14:00 - 14:30",
    "14:30 - 15:00",
    "15:30 - 16:00",
  ];

  void _addSlot() async {
    setState(() {
      _isLoading = true;
    });

    final state = Provider.of<AppState>(context, listen: false);
    try {
      await state.addTimeSlot(_selectedDate, _startTime, _endTime);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Time slot added to availability calendar."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mySlots = state.timeSlots.where((s) => s.vetUid == state.currentUser?.uid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Calendar Slots"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Create Slot Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Availability Slot",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker Trigger
                    ListTile(
                      leading: const Icon(Icons.date_range_rounded, color: AppTheme.tealSecondary),
                      title: const Text("Select Slot Date"),
                      subtitle: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                      tileColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Time presets Dropdown
                    const Text("Select Time Block (30-min blocks)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF444444) : const Color(0xFFEBE3D5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: "$_startTime - $_endTime",
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                          onChanged: (val) {
                            if (val != null) {
                              final parts = val.split(" - ");
                              setState(() {
                                _startTime = parts[0];
                                _endTime = parts[1];
                              });
                            }
                          },
                          items: _timePresets.map((preset) {
                            return DropdownMenuItem(
                              value: preset,
                              child: Text(preset),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _addSlot,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text("Publish Availability Slot"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.tealSecondary,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Published Available Slots",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            mySlots.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "No published availability slots. Add slots above to enable owner bookings.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mySlots.length,
                    itemBuilder: (context, index) {
                      final slot = mySlots[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: slot.isBooked ? Colors.amber.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                            child: Icon(
                              slot.isBooked ? Icons.lock_rounded : Icons.lock_open_rounded,
                              color: slot.isBooked ? Colors.amber : Colors.green,
                            ),
                          ),
                          title: Text("${slot.date.day}/${slot.date.month}/${slot.date.year}"),
                          subtitle: Text("Time: ${slot.startTime} - ${slot.endTime} (${slot.isBooked ? 'Booked' : 'Available'})"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                            onPressed: () async {
                              await state.deleteTimeSlot(slot.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Slot deleted successfully.")),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
