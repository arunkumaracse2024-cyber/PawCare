import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../state/app_state.dart';
import 'package:provider/provider.dart';

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

  List<String> _availableBreeds = [];

  bool get _isEditMode => widget.pet != null;

  @override
  void initState() {
    super.initState();
    _name = widget.pet?.name ?? '';
    _species = widget.pet?.species ?? 'dog';
    _breed = widget.pet?.breed ?? '';
    _age = widget.pet?.age ?? 1.0;
    _weight = widget.pet?.weight ?? 5.0;
    _photoPath = widget.pet?.photoPath ?? '';

    // Load available breeds based on initial species selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBreedList();
    });
  }

  void _updateBreedList() {
    final state = Provider.of<AppState>(context, listen: false);
    final relevantBreeds = state.breeds.where((b) => b.species.toLowerCase() == _species.toLowerCase()).toList();

    setState(() {
      _availableBreeds = relevantBreeds.map((b) => b.breed).toList();
      if (_availableBreeds.isNotEmpty && !_availableBreeds.contains(_breed)) {
        _breed = _availableBreeds.first;
      }
    });
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final state = Provider.of<AppState>(context, listen: false);

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
          'Are you sure you want to delete ${_name}? This action will permanently remove all logs, reminders and files.',
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
            content: Text('${_name} has been deleted.'),
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
                          items: state.breeds.map((b) => b.species).toSet().map((species) {
                            return DropdownMenuItem<String>(
                              value: species.toLowerCase(),
                              child: Text(species[0].toUpperCase() + species.substring(1)),
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

                    // Age Slider Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Age (Years)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${_age.toStringAsFixed(1)} yrs',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _age,
                      min: 0.1,
                      max: 20.0,
                      divisions: 199,
                      label: '${_age.toStringAsFixed(1)} yrs',
                      onChanged: (val) {
                        setState(() {
                          _age = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Weight Slider Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weight (kg)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${_weight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _weight,
                      min: 0.1,
                      max: 100.0,
                      divisions: 999,
                      label: '${_weight.toStringAsFixed(1)} kg',
                      onChanged: (val) {
                        setState(() {
                          _weight = val;
                        });
                      },
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
