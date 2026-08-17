import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/appointment.dart';
import '../../theme/app_theme.dart';

class VisitNotesScreen extends StatefulWidget {
  final Appointment appointment;

  const VisitNotesScreen({super.key, required this.appointment});

  @override
  State<VisitNotesScreen> createState() => _VisitNotesScreenState();
}

class _VisitNotesScreenState extends State<VisitNotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'checkup';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = Provider.of<AppState>(context, listen: false);

    try {
      await state.updateAppointmentStatus(
        widget.appointment.id,
        'completed',
        postVisitNotes: _notesController.text.trim(),
        category: _category,
        instructionTitle: _titleController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Visit completed. Instructions saved to pet's profile."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to requests list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Visit Notes"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Record Post-Visit Instructions & Prescription",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                "These details will feed directly into the owner's Merged Todo Care Feed and satisfy generic checklist items.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Category Selector
              const Text("Care Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    value: _category,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _category = val;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'checkup', child: Text("Checkup / Vitals")),
                      DropdownMenuItem(value: 'vaccination', child: Text("Vaccination Booster")),
                      DropdownMenuItem(value: 'medicine', child: Text("Prescription / Medicine")),
                      DropdownMenuItem(value: 'feeding', child: Text("Diet / Nutrition Note")),
                      DropdownMenuItem(value: 'grooming', child: Text("Grooming / Skin Treatment")),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Instruction Title",
                  hintText: "e.g. Heartworm medicine dose, Give 2 drops ear medication...",
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Please enter a title";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Detailed Instructions / Notes",
                  hintText: "Enter prescriptions, dosage rules, or follow-up timelines...",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Please enter detailed notes";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_rounded),
                label: const Text("Save Visit and Complete Token"),
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


