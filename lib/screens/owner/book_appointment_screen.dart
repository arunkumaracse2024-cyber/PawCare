import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/vet_profile.dart';
import '../../models/time_slot.dart';
import '../../theme/app_theme.dart';

class BookAppointmentScreen extends StatefulWidget {
  final VetProfile vet;

  const BookAppointmentScreen({super.key, required this.vet});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  TimeSlot? _selectedSlot;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select or add a pet first before booking."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an available time slot."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await state.bookAppointment(
        petId: state.selectedPet!.id,
        vetUid: widget.vet.uid,
        slotId: _selectedSlot!.id,
        dateTime: _selectedSlot!.date,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 8),
                Text("Booking Confirmed"),
              ],
            ),
            content: Text(
              "Your appointment token for ${state.selectedPet!.name} at ${widget.vet.clinicName} has been booked! "
              "Check the status in your Appointments screen.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Go back to directory
                },
                child: const Text("Okay"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to book appointment: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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

    // Filter available slots for this vet
    final availableSlots = state.timeSlots
        .where((s) => s.vetUid == widget.vet.uid && !s.isBooked)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vet Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.tealSecondary.withValues(alpha: 0.12),
                        child: const Icon(Icons.local_hospital_rounded, color: AppTheme.tealSecondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vet.clinicName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              widget.vet.specialization,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Select Available Slot",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              availableSlots.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF222222) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          "No slots available currently. Please consult another vet or wait for updates.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableSlots.length,
                        itemBuilder: (context, index) {
                          final slot = availableSlots[index];
                          final isSelected = _selectedSlot?.id == slot.id;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSlot = slot;
                              });
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12, bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.tealSecondary.withValues(alpha: 0.15)
                                    : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.tealSecondary
                                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${slot.date.day}/${slot.date.month}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${slot.startTime} - ${slot.endTime}",
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.tealSecondary : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 24),

              // Reason / Visit Notes input
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Reason for Appointment / Symptoms",
                  hintText: "e.g. routine checkup, vaccination booster, ear infection description...",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a reason for booking";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text("Confirm Appointment Booking"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.tealSecondary,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}



