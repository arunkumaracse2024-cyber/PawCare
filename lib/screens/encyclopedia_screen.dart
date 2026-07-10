import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../models/encyclopedia.dart';

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

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    _tabController = TabController(
      length: state.speciesList.length,
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

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.speciesList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Encyclopedia')),
        body: const Center(child: CircularProgressIndicator()),
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
          tabs: state.speciesList.map((s) => Tab(text: s.name)).toList(),
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
              children: state.speciesList.map((species) {
                final filteredBreeds = species.breeds.where((b) {
                  return b.name.toLowerCase().contains(_searchQuery) ||
                      b.temperament.toLowerCase().contains(_searchQuery);
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
                    return _buildBreedCard(context, species, breed, isDark);
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
    Species species,
    Breed breed,
    bool isDark,
  ) {
    final avatarColor = species.id.toLowerCase() == 'dog'
        ? AppTheme.orangePrimary
        : species.id.toLowerCase() == 'cat'
        ? AppTheme.tealSecondary
        : Colors.amber;

    final speciesIcon = species.id.toLowerCase() == 'dog'
        ? Icons.pets_rounded
        : species.id.toLowerCase() == 'cat'
        ? Icons.catching_pokemon_rounded
        : Icons.flutter_dash_rounded;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BreedDetailScreen(species: species, breed: breed),
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
                breed.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                breed.temperament.split(',').first,
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
  final Species species;
  final Breed breed;

  const BreedDetailScreen({
    super.key,
    required this.species,
    required this.breed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final avatarColor = species.id.toLowerCase() == 'dog'
        ? AppTheme.orangePrimary
        : species.id.toLowerCase() == 'cat'
        ? AppTheme.tealSecondary
        : Colors.amber;

    final speciesIcon = species.id.toLowerCase() == 'dog'
        ? Icons.pets_rounded
        : species.id.toLowerCase() == 'cat'
        ? Icons.catching_pokemon_rounded
        : Icons.flutter_dash_rounded;

    return Scaffold(
      appBar: AppBar(title: Text(breed.name)),
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
                    breed.lifespan,
                    Icons.hourglass_empty_rounded,
                    Colors.deepOrangeAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoSquare(
                    'Size/Weight',
                    breed.sizeRange,
                    Icons.monitor_weight_outlined,
                    AppTheme.tealSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Temperament & Care Tags
            const Text(
              'Temperament',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: breed.temperament.split(',').map((t) {
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

            // Care Guide
            const Text(
              'Care Guidelines',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  breed.careGuide,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Fun Fact Action Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mascot Fun Fact!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          breed.funFact,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black.withOpacity(0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- FOOD SAFETY GUIDE ---
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
                    foods: species.safeFoods,
                    isSafe: true,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFoodContainer(
                    title: 'Toxic Foods',
                    foods: species.unsafeFoods,
                    isSafe: false,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // --- VACCINE RECOMMENDATIONS ---
            const Text(
              'Recommended Core Vaccines',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: species.recommendedVaccines.map((v) {
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
                                        v.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )
                                    : Text(
                                        v.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                const SizedBox(height: 2),
                                Text(
                                  'Timing: ${v.suggestedAge}',
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
                      'Disclaimer: This guide is for informational purposes only. Consult a veterinarian immediately for professional health/diet checkups.',
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
              value,
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
