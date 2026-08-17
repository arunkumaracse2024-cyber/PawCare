import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../state/encyclopedia_provider.dart';
import '../../../models/food.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final encyclopedia = Provider.of<EncyclopediaProvider>(context, listen: false);
    _tabController = TabController(length: encyclopedia.speciesList.length, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final encyclopedia = Provider.of<EncyclopediaProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (encyclopedia.speciesList.isEmpty || encyclopedia.foods.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Food Safety Search')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Safety Search'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.orangePrimary,
          labelColor: AppTheme.orangeDeep,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
          tabs: encyclopedia.speciesList.map((s) => Tab(text: s.name)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foods (e.g. Chocolate, Apple)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: encyclopedia.speciesList.map((species) {
                final speciesFoods = encyclopedia.foods.where((f) => f.species == species.id).toList();
                final filteredFoods = speciesFoods.where((f) {
                  return f.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredFoods.isEmpty) {
                  return Center(
                    child: Text(
                      'No foods found matching "$_searchQuery"',
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];
                    return _buildFoodCard(food, isDark);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Food food, bool isDark) {
    final color = food.isSafe ? Colors.green : Colors.red;
    final icon = food.isSafe ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





