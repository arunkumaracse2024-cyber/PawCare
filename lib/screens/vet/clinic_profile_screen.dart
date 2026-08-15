import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class ClinicProfileScreen extends StatefulWidget {
  const ClinicProfileScreen({super.key});

  @override
  State<ClinicProfileScreen> createState() => _ClinicProfileScreenState();
}

class _ClinicProfileScreenState extends State<ClinicProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _specializationController = TextEditingController();
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    final profile = state.currentVetProfile;
    if (profile != null) {
      _clinicNameController.text = profile.clinicName;
      _addressController.text = profile.address;
      _specializationController.text = profile.specialization;
      _isVerified = profile.isVerified;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final state = Provider.of<AppState>(context, listen: false);
    try {
      await state.updateVetProfile(
        clinicName: _clinicNameController.text.trim(),
        address: _addressController.text.trim(),
        specialization: _specializationController.text.trim(),
        workingHours: {'Mon-Fri': '09:00 - 17:00'},
        isVerified: _isVerified,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Clinic profile updated successfully."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    _clinicNameController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clinic Profile Settings"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _clinicNameController,
                decoration: const InputDecoration(
                  labelText: "Clinic Name",
                  prefixIcon: Icon(Icons.local_hospital_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Enter clinic name";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Clinic Address",
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Enter address";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: "Clinic Specialization",
                  prefixIcon: Icon(Icons.star_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Enter specialization";
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Mock Verified checkbox
              Card(
                color: AppTheme.tealSecondary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.tealSecondary.withOpacity(0.3)),
                ),
                child: CheckboxListTile(
                  title: const Text(
                    "Verify Clinic (KYC Demo Placeholder)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    "Toggle to simulate official veterinary license approval in demo mode.",
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isVerified,
                  activeColor: AppTheme.tealSecondary,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _isVerified = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _save,
                child: const Text("Save Clinic Settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
