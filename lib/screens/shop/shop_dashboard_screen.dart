import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../auth_screen.dart';
import 'pet_catalog_screen.dart';
import 'sale_record_screen.dart';
import 'partner_vets_screen.dart';
import '../shared/future_scope_screen.dart';

class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    final listedPets = state.shopPets.where((p) => !p.isLinked).toList();
    final soldPets = state.shopPets.where((p) => p.isLinked).toList();
    final partnersCount = state.currentShopProfile?.partnerVetIds.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(
              state.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => state.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await state.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shop Welcome Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.orangePrimary, AppTheme.orangeDeep],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.currentShopProfile?.shopName ?? "Welcome Shop Admin",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.currentShopProfile?.address ?? "Update address in settings",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: "Active Listed",
                    value: "${listedPets.length}",
                    icon: Icons.inventory_2_rounded,
                    color: AppTheme.orangePrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: "Total Sold",
                    value: "${soldPets.length}",
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.tealSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: "Partner Vets",
                    value: "$partnersCount",
                    icon: Icons.people_rounded,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Admin Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.35,
              children: [
                _buildActionCard(
                  context,
                  title: "Pet Catalog",
                  description: "Manage shop inventory records",
                  icon: Icons.pets_rounded,
                  color: AppTheme.orangePrimary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PetCatalogScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: "Record Sale",
                  description: "Sell & generate link invites",
                  icon: Icons.sell_rounded,
                  color: AppTheme.tealSecondary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SaleRecordScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: "Partner Vets",
                  description: "Manage linked veterinarians",
                  icon: Icons.local_hospital_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PartnerVetsScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: "Future Scope",
                  description: "Static mock roadmap screens",
                  icon: Icons.next_plan_rounded,
                  color: Colors.blueGrey,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FutureScopeScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

