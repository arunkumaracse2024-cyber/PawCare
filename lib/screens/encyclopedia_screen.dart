import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../models/pet_breed.dart';

class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _availableSpecies = [];

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    
    // Extract unique species from the loaded breeds
    final Set<String> speciesSet = {};
    for (var breed in state.breeds) {
      speciesSet.add(breed.species.toLowerCase());
    }
    _availableSpecies = speciesSet.toList()..sort();
    

    _tabController = TabController(
      length: _availableSpecies.isEmpty ? 1 : _availableSpecies.length,
      vsync: this,
    );
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.isDatasetLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Encyclopedia')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_availableSpecies.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Encyclopedia')),
        body: const Center(child: Text('No breed data available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Encyclopedia'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.orangePrimary,
          labelColor: AppTheme.orangeDeep,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
          tabs: _availableSpecies.map((s) => Tab(text: _capitalize(s))).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search breeds...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          // Tab Content List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _availableSpecies.map((speciesStr) {
                // Filter breeds for this species
                final speciesBreeds = state.breeds.where((b) => b.species == speciesStr).toList();
                
                final filteredBreeds = speciesBreeds.where((b) {
                  return b.breed.toLowerCase().contains(_searchQuery) ||
                      b.temperament.join(' ').toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredBreeds.isEmpty) {
                  return Center(
                    child: Text(
                      'No breeds found matching "$_searchQuery"',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filteredBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = filteredBreeds[index];
                    return _buildBreedCard(context, breed, isDark);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedCard(
    BuildContext context,
    PetBreed breed,
    bool isDark,
  ) {
    final avatarColor = breed.species == 'dog'
        ? AppTheme.orangePrimary
        : breed.species == 'cat'
        ? AppTheme.tealSecondary
        : Colors.amber;

    final speciesIcon = breed.species == 'dog'
        ? Icons.pets_rounded
        : breed.species == 'cat'
        ? Icons.catching_pokemon_rounded
        : Icons.flutter_dash_rounded;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BreedDetailScreen(breed: breed),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Hero(
                tag: 'breed_avatar_${breed.id}',
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: avatarColor.withOpacity(0.15),
                  child: Icon(speciesIcon, color: avatarColor, size: 36),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                breed.breed,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                breed.temperament.isNotEmpty ? breed.temperament.first : '',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BreedDetailScreen extends StatelessWidget {
  final PetBreed breed;

  const BreedDetailScreen({
    super.key,
    required this.breed,
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final avatarColor = breed.species == 'dog'
        ? AppTheme.orangePrimary
        : breed.species == 'cat'
        ? AppTheme.tealSecondary
        : Colors.amber;

    final speciesIcon = breed.species == 'dog'
        ? Icons.pets_rounded
        : breed.species == 'cat'
        ? Icons.catching_pokemon_rounded
        : Icons.flutter_dash_rounded;

    // Retrieve foods for this species from AppState
    final safeFoods = state.foods
        .where((f) => f.species.contains(breed.species) && f.classification == 'safe')
        .map((f) => f.foodName)
        .toList();
    final toxicFoods = state.foods
        .where((f) => f.species.contains(breed.species) && f.classification == 'toxic')
        .map((f) => f.foodName)
        .toList();

    // Retrieve vaccines for this species
    final speciesVaccines = state.vaccines.where((v) => v.species == breed.species).toList();

    String lifespanDisplay = breed.lifespanString ?? '';
    if (lifespanDisplay.isEmpty && breed.lifespanYears != null) {
      lifespanDisplay = '${breed.lifespanYears!.min}-${breed.lifespanYears!.max} years';
    }

    String weightDisplay = breed.weightString ?? '';
    if (weightDisplay.isEmpty && breed.weightKg != null) {
      weightDisplay = '${breed.weightKg!.min}-${breed.weightKg!.max} kg';
    }

    return Scaffold(
      appBar: AppBar(title: Text(breed.breed)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header Card
            Card(
              color: avatarColor.withOpacity(0.12),
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Hero(
                  tag: 'breed_avatar_${breed.id}',
                  child: Center(
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white,
                      child: Icon(speciesIcon, color: avatarColor, size: 54),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Breed Info Grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoSquare(
                    'Lifespan',
                    lifespanDisplay,
                    Icons.hourglass_empty_rounded,
                    Colors.deepOrangeAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoSquare(
                    'Size/Weight',
                    weightDisplay,
                    Icons.monitor_weight_outlined,
                    AppTheme.tealSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Temperament & Care Tags
            if (breed.temperament.isNotEmpty) ...[
              const Text(
                'Temperament',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: breed.temperament.map((t) {
                  return Chip(
                    label: Text(t.trim()),
                    backgroundColor: isDark
                        ? const Color(0xFF2C2C2C)
                        : Colors.grey.shade100,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Description
            if (breed.description.isNotEmpty) ...[
              const Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    breed.description,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Care Guidelines
            if (breed.exerciseNeeds.isNotEmpty || breed.groomingNeeds.isNotEmpty) ...[
               const Text(
                'Care Guidelines',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (breed.exerciseNeeds.isNotEmpty)
                        Text('Exercise: ${breed.exerciseNeeds}', style: const TextStyle(height: 1.4)),
                      if (breed.groomingNeeds.isNotEmpty)
                        Text('Grooming: ${breed.groomingNeeds}', style: const TextStyle(height: 1.4)),
                      if (breed.climatePreference.isNotEmpty)
                        Text('Climate: ${breed.climatePreference}', style: const TextStyle(height: 1.4)),
                    ]
                  )
                ),
              ),
              const SizedBox(height: 24),
            ],

            // --- FOOD SAFETY GUIDE ---
            if (safeFoods.isNotEmpty || toxicFoods.isNotEmpty) ...[
              const Text(
                'Food Safety Checker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFoodContainer(
                      title: 'Safe Foods',
                      foods: safeFoods,
                      isSafe: true,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFoodContainer(
                      title: 'Toxic Foods',
                      foods: toxicFoods,
                      isSafe: false,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],

            // --- VACCINE RECOMMENDATIONS ---
            if (speciesVaccines.isNotEmpty) ...[
              const Text(
                'Recommended Core Vaccines',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: speciesVaccines.map((v) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppTheme.tealSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextTheme.of(context).bodyMedium == null
                                      ? Text(
                                          v.vaccineName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        )
                                      : Text(
                                          v.vaccineName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Timing: ${v.recommendedAge}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (v.purpose.isNotEmpty)
                                    Text(
                                      v.purpose,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Health Disclaimer warning
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Disclaimer: Vaccination schedules may vary by region, lifestyle, health status and veterinary recommendation. This guide is for informational purposes only. Consult a veterinarian immediately for professional health/diet checkups.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSquare(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodContainer({
    required String title,
    required List<String> foods,
    required bool isSafe,
    required bool isDark,
  }) {
    final accentColor = isSafe ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSafe ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (foods.isEmpty)
             const Text('No data', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ...foods.map((food) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white60 : Colors.black45,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(food, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

