import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class PetProfileScreen extends StatefulWidget {
  final Pet? pet; // Null if adding a new pet

  const PetProfileScreen({super.key, this.pet});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _species;
  late String _breed;
  late double _age;
  late double _weight;
  late String _photoPath;

  bool _isWeightInLb = false; // Toggle for lb/kg
  List<String> _availableBreeds = [];

  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  bool get _isEditMode => widget.pet != null;

  // Species Bounds Constants (in kg)
  double getMinAge(String species) => 0.0;
  double getMaxAge(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return 25.0;
      case 'bird':
        return 80.0;
      case 'dog':
      default:
        return 20.0;
    }
  }

  double getMinWeightKg(String species) {
    switch (species.toLowerCase()) {
      case 'bird':
        return 0.01;
      case 'cat':
      case 'dog':
      default:
        return 0.5;
    }
  }

  double getMaxWeightKg(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return 12.0;
      case 'bird':
        return 2.0;
      case 'dog':
      default:
        return 90.0;
    }
  }

  // Weight conversion helpers
  double kgToLb(double kg) => double.parse((kg * 2.20462).toStringAsFixed(2));
  double lbToKg(double lb) => double.parse((lb / 2.20462).toStringAsFixed(2));

  @override
  void initState() {
    super.initState();
    _name = widget.pet?.name ?? '';
    _species = widget.pet?.species ?? 'dog';
    _breed = widget.pet?.breed ?? '';
    _age = widget.pet?.age ?? 1.0;
    _weight = widget.pet?.weight ?? 5.0;
    _photoPath = widget.pet?.photoPath ?? '';

    _ageController.text = _age.toString();
    _weightController.text = _weight.toString(); // Default in kg

    // Load available breeds based on initial species selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBreedList();
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateBreedList() {
    final state = Provider.of<AppState>(context, listen: false);
    final species = state.speciesList.firstWhere(
      (s) => s.id.toLowerCase() == _species.toLowerCase(),
      orElse: () => state.speciesList.first,
    );

    setState(() {
      _availableBreeds = species.breeds.map((b) => b.name).toList();
      if (_availableBreeds.isNotEmpty && !_availableBreeds.contains(_breed)) {
        _breed = _availableBreeds.first;
      }
    });
  }

  void _toggleWeightUnit(bool toLb) {
    if (_isWeightInLb == toLb) return;

    final currentVal = double.tryParse(_weightController.text) ?? 0.0;
    setState(() {
      _isWeightInLb = toLb;
      if (toLb) {
        // kg -> lb
        _weightController.text = kgToLb(currentVal).toString();
      } else {
        // lb -> kg
        _weightController.text = lbToKg(currentVal).toString();
      }
    });
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final state = Provider.of<AppState>(context, listen: false);

    // Read age
    _age = double.parse(_ageController.text.trim());

    // Read weight and store in kg internally
    final inputWeight = double.parse(_weightController.text.trim());
    _weight = _isWeightInLb ? lbToKg(inputWeight) : inputWeight;

    try {
      if (_isEditMode) {
        final updatedPet = widget.pet!.copyWith(
          name: _name,
          species: _species,
          breed: _breed,
          age: _age,
          weight: _weight,
          photoPath: _photoPath,
        );
        await state.updatePet(updatedPet);
      } else {
        await state.addPet(
          name: _name,
          species: _species,
          breed: _breed,
          age: _age,
          weight: _weight,
          photoPath: _photoPath,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Pet profile updated successfully!'
                  : 'New pet profile added!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save pet profile: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _deletePet() async {
    final state = Provider.of<AppState>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet Profile?'),
        content: Text(
          'Are you sure you want to delete $_name? This action will permanently remove all logs, reminders and files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pop(); // Dismiss profile screen
      await state.deletePet(widget.pet!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$widget.pet!.name has been deleted.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final speciesLabel = _species.toUpperCase();
    final minAge = getMinAge(_species);
    final maxAge = getMaxAge(_species);
    final minWeight = getMinWeightKg(_species);
    final maxWeight = getMaxWeightKg(_species);

    final displayMinWeight = _isWeightInLb ? kgToLb(minWeight) : minWeight;
    final displayMaxWeight = _isWeightInLb ? kgToLb(maxWeight) : maxWeight;
    final unitLabel = _isWeightInLb ? 'lb' : 'kg';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pet Profile' : 'Add New Pet'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              onPressed: _deletePet,
              tooltip: 'Delete Profile',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Circular Mascot
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _species.toLowerCase() == 'dog'
                              ? Icons.pets_rounded
                              : _species.toLowerCase() == 'cat'
                              ? Icons.catching_pokemon_rounded
                              : Icons.flutter_dash_rounded,
                          size: 54,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 20),

                    // Species Dropdown Selection
                    const Text(
                      'Species',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF444444)
                              : const Color(0xFFEBE3D5),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _species,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          onChanged: (String? newVal) {
                            if (newVal != null) {
                              setState(() {
                                _species = newVal;
                              });
                              _updateBreedList();
                            }
                          },
                          items: state.speciesList.map((s) {
                            return DropdownMenuItem<String>(
                              value: s.id,
                              child: Text(s.name),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Breed Dropdown Selection
                    const Text(
                      'Breed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF444444)
                              : const Color(0xFFEBE3D5),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _breed.isEmpty && _availableBreeds.isNotEmpty
                              ? _availableBreeds.first
                              : _breed,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          onChanged: (String? newVal) {
                            if (newVal != null) {
                              setState(() {
                                _breed = newVal;
                              });
                            }
                          },
                          items: _availableBreeds.map((String b) {
                            return DropdownMenuItem<String>(
                              value: b,
                              child: Text(b),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Age Numeric Text Field
                    TextFormField(
                      controller: _ageController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Age (Years)',
                        prefixIcon: const Icon(Icons.cake_outlined),
                        helperText: 'Valid range: $minAge - $maxAge years for $speciesLabel',
                        helperStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.tealSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter age';
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null) {
                          return 'Enter a valid number';
                        }
                        if (parsed < minAge || parsed > maxAge) {
                          return 'Age must be between $minAge and $maxAge years for $speciesLabel';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Weight Numeric Text Field and Toggle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Weight ($unitLabel)',
                              prefixIcon: const Icon(Icons.fitness_center_rounded),
                              helperText: 'Valid range: $displayMinWeight - $displayMaxWeight $unitLabel for $speciesLabel',
                              helperStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.tealSecondary),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter weight';
                              }
                              final parsed = double.tryParse(value.trim());
                              if (parsed == null) {
                                return 'Enter a valid number';
                              }
                              if (parsed < displayMinWeight || parsed > displayMaxWeight) {
                                return 'Weight must be between $displayMinWeight and $displayMaxWeight $unitLabel for $speciesLabel';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: ToggleButtons(
                            borderRadius: BorderRadius.circular(12),
                            isSelected: [!_isWeightInLb, _isWeightInLb],
                            onPressed: (index) {
                              _toggleWeightUnit(index == 1);
                            },
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Text('kg'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Text('lb'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Commit Button
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: Text(
                        _isEditMode ? 'Save Changes' : 'Create Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
