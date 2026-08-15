import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class PetCatalogScreen extends StatefulWidget {
  const PetCatalogScreen({super.key});

  @override
  State<PetCatalogScreen> createState() => _PetCatalogScreenState();
}

class _PetCatalogScreenState extends State<PetCatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _healthController = TextEditingController();

  String _species = 'dog';

  // Species bounds validation helpers
  double getMinAge() => 0.0;
  double getMaxAge() {
    switch (_species) {
      case 'cat': return 25.0;
      case 'bird': return 80.0;
      case 'dog':
      default: return 20.0;
    }
  }
  double getMinWeight() {
    switch (_species) {
      case 'bird': return 0.01;
      case 'cat':
      case 'dog':
      default: return 0.5;
    }
  }
  double getMaxWeight() {
    switch (_species) {
      case 'cat': return 12.0;
      case 'bird': return 2.0;
      case 'dog':
      default: return 90.0;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = Provider.of<AppState>(context, listen: false);

    try {
      await state.addCatalogPet(
        name: _nameController.text.trim(),
        species: _species,
        breed: _breedController.text.trim(),
        age: double.parse(_ageController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        healthNotes: _healthController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pet added to catalog inventory successfully."),
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
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final listedPets = state.shopPets.where((p) => !p.isLinked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pet Catalog Inventory"),
      ),
      body: Column(
        children: [
          Expanded(
            child: listedPets.isEmpty
                ? const Center(
                    child: Text("No listed pets in shop catalog inventory."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: listedPets.length,
                    itemBuilder: (context, index) {
                      final pet = listedPets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.orangePrimary.withOpacity(0.12),
                            child: Icon(
                              pet.species.toLowerCase() == 'dog'
                                  ? Icons.pets_rounded
                                  : pet.species.toLowerCase() == 'cat'
                                      ? Icons.catching_pokemon_rounded
                                      : Icons.flutter_dash_rounded,
                              color: AppTheme.orangePrimary,
                            ),
                          ),
                          title: Text(
                            pet.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${pet.breed} • ${pet.age} yrs • ${pet.weight} kg"),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddPetDialog(context, isDark, theme),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Add Inventory Pet"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPetDialog(BuildContext context, bool isDark, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final minAge = getMinAge();
            final maxAge = getMaxAge();
            final minWeight = getMinWeight();
            final maxWeight = getMaxWeight();

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Add Inventory Pet Record",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Pet Name / Identifier",
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Please enter a name";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Species Dropdown
                      const Text("Species", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF444444) : const Color(0xFFEBE3D5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _species,
                            isExpanded: true,
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  _species = val;
                                });
                                setState(() {
                                  _species = val;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'dog', child: Text("Dog")),
                              DropdownMenuItem(value: 'cat', child: Text("Cat")),
                              DropdownMenuItem(value: 'bird', child: Text("Bird")),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: "Breed",
                          prefixIcon: Icon(Icons.pets_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Please enter breed";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _ageController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Age (Years)",
                          prefixIcon: const Icon(Icons.cake_outlined),
                          helperText: "Valid range: $minAge - $maxAge years for $_species",
                          helperStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.tealSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Please enter age";
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null) return "Enter a valid number";
                          if (parsed < minAge || parsed > maxAge) {
                            return "Age must be $minAge - $maxAge years for $_species";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Weight (kg)",
                          prefixIcon: const Icon(Icons.fitness_center_rounded),
                          helperText: "Valid range: $minWeight - $maxWeight kg for $_species",
                          helperStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.tealSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Please enter weight";
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null) return "Enter a valid number";
                          if (parsed < minWeight || parsed > maxWeight) {
                            return "Weight must be $minWeight - $maxWeight kg for $_species";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _healthController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Initial Health status / Notes",
                          hintText: "e.g. healthy, first deworming given, friendly temperament...",
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text("Save Catalog Pet"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
