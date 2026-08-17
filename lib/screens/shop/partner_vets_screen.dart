import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class PartnerVetsScreen extends StatefulWidget {
  const PartnerVetsScreen({super.key});

  @override
  State<PartnerVetsScreen> createState() => _PartnerVetsScreenState();
}

class _PartnerVetsScreenState extends State<PartnerVetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _inviteVet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final state = Provider.of<AppState>(context, listen: false);
    final success = await state.invitePartnerVet(_emailController.text.trim());

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Partnership confirmed successfully! Vet linked."),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vet account not found. Please verify the email."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final partners = state.allVets
        .where((vet) => vet.partnerShopIds.contains(state.currentUser?.uid))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Partnered Veterinarians"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Send Partnership Invite Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Add Partner Veterinarian",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Enter the email of a registered Veterinarian to establish a partner link. This will enable buyers of your pets to browse this clinic.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Vet Account Email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || !value.contains('@')) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              onPressed: _inviteVet,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text("Establish Partnership"),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tealSecondary),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Active Vet Partners",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            partners.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "No partner vets added yet. Establish your first partnership above!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: partners.length,
                    itemBuilder: (context, index) {
                      final vet = partners[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.tealSecondary.withValues(alpha: 0.12),
                            child: const Icon(Icons.local_hospital_rounded, color: AppTheme.tealSecondary),
                          ),
                          title: Text(
                            vet.clinicName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${vet.specialization}\n${vet.address}"),
                          isThreeLine: true,
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



