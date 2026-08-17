import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../state/app_state.dart';
import '../../models/pet.dart';
import '../../theme/app_theme.dart';

class SaleRecordScreen extends StatefulWidget {
  const SaleRecordScreen({super.key});

  @override
  State<SaleRecordScreen> createState() => _SaleRecordScreenState();
}

class _SaleRecordScreenState extends State<SaleRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaxController = TextEditingController();
  final _feedController = TextEditingController();

  Pet? _selectedPetForSale;
  String _generatedCode = '';
  bool _isLoading = false;

  void _recordSale() async {
    if (_selectedPetForSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a pet to sell."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final state = Provider.of<AppState>(context, listen: false);
    final code = await state.recordSaleAndGenerateCode(
      petId: _selectedPetForSale!.id,
      saleVaccinationNote: _vaxController.text.trim(),
      saleFeedingNote: _feedController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _generatedCode = code;
    });
  }

  @override
  void dispose() {
    _vaxController.dispose();
    _feedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final listedPets = state.shopPets.where((p) => !p.isLinked && (p.linkCode == null || p.linkCode!.isEmpty)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Manual Sale"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_generatedCode.isNotEmpty) ...[
              // Display generated link code
              Card(
                color: AppTheme.tealSecondary.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppTheme.tealSecondary, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.tealSecondary, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        "Sale Recorded Successfully!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Give this code to the pet owner to link the pet in their app:",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _generatedCode,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppTheme.orangeDeep,
                              ),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              icon: const Icon(Icons.copy_all_rounded, color: AppTheme.tealSecondary),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _generatedCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Code copied to clipboard!")),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _generatedCode = '';
                            _selectedPetForSale = null;
                            _vaxController.clear();
                            _feedController.clear();
                          });
                        },
                        child: const Text("Record Another Sale"),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Form to enter sale info
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Select Pet from Catalog",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    listedPets.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              "No listed pets available for sale in inventory.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF444444) : const Color(0xFFEBE3D5),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Pet>(
                                value: _selectedPetForSale,
                                isExpanded: true,
                                hint: const Text("Select pet to sell"),
                                dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                                onChanged: (pet) {
                                  setState(() {
                                    _selectedPetForSale = pet;
                                  });
                                },
                                items: listedPets.map((pet) {
                                  return DropdownMenuItem(
                                    value: pet,
                                    child: Text("${pet.name} (${pet.breed})"),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                    const SizedBox(height: 24),

                    const Text(
                      "Sale-Time Care Notes (Optional)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _vaxController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Vaccination instructions / History",
                        hintText: "e.g. first vaccine already given on 2026-08-01, next booster due in 2 weeks...",
                        prefixIcon: Icon(Icons.vaccines_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _feedController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Transition feeding guidelines",
                        hintText: "e.g. feed high-protein dry kibble twice daily, do not give dairy...",
                        prefixIcon: Icon(Icons.restaurant_rounded),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _recordSale,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text("Record Sale & Generate Link Code"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.tealSecondary,
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

