import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../models/pet.dart';
import '../../models/reminder.dart';
import 'pet_profile_screen.dart';
import 'encyclopedia_screen.dart';
import 'checklist_screen.dart';
import 'reminder_screen.dart';
import 'advisory_screen.dart';
import 'behaviour_screen.dart';
import 'health_wallet_screen.dart';
import 'auth_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_rounded, color: AppTheme.orangePrimary),
            SizedBox(width: 8),
            Text('PawCare'),
          ],
        ),
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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.pets.isEmpty
          ? _buildEmptyState(context, isDark)
          : _buildDashboardContent(context, state, isDark),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.orangePrimary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_to_photos_rounded,
                size: 80,
                color: AppTheme.orangePrimary,
              ),
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            const SizedBox(height: 32),
            const Text(
              'No Pets Added Yet!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first pet to begin tracking vaccinations, behaviors, and milestone checklists.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PetProfileScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add a Pet Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AppState state,
    bool isDark,
  ) {
    final pet = state.selectedPet!;

    // Checklist progress calculation
    final checklist = pet.checklist;
    final totalChecklist = checklist.length;
    final completedChecklist = checklist.where((c) => c.isDone).length;
    final double progressPercent = totalChecklist > 0
        ? (completedChecklist / totalChecklist)
        : 0.0;

    return RefreshIndicator(
      onRefresh: () => state.refreshState(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TOP PET INTERACTIVE SWITCHER ---
            _buildPetSwitcher(context, state, isDark),
            const SizedBox(height: 24),

            // --- QUICK STATS CARD ---
            _buildQuickStatsCard(context, pet, isDark),
            const SizedBox(height: 24),

            // --- PROGRESS BAR HIGHLIGHT ---
            _buildMilestonesProgress(
              context,
              pet,
              completedChecklist,
              totalChecklist,
              progressPercent,
              isDark,
            ),
            const SizedBox(height: 24),

            // --- REMINDERS LIST ---
            _buildDashboardReminders(context, state, isDark),
            const SizedBox(height: 24),

            // --- NAVIGATION GRID ---
            const Text(
              'Quick Modules',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildNavigationGrid(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSwitcher(BuildContext context, AppState state, bool isDark) {
    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.pets.length + 1,
        itemBuilder: (context, index) {
          if (index == state.pets.length) {
            // "Add Pet" Button Card
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PetProfileScreen()),
                );
              },
              child: Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2C)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.orangePrimary.withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.orangePrimary,
                  size: 28,
                ),
              ),
            );
          }

          final pet = state.pets[index];
          final isSelected = state.selectedPet?.id == pet.id;
          final avatarColor = pet.species.toLowerCase() == 'dog'
              ? AppTheme.orangePrimary
              : pet.species.toLowerCase() == 'cat'
              ? AppTheme.tealSecondary
              : Colors.amber;

          return GestureDetector(
            onTap: () => state.selectPet(pet),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.orangePrimary.withOpacity(0.15)
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.orangePrimary
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarColor,
                    child: Text(
                      pet.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isDark ? Colors.white : AppTheme.orangeDeep)
                              : (isDark
                                    ? Colors.white70
                                    : Colors.black.withOpacity(0.8)),
                        ),
                      ),
                      Text(
                        pet.breed,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStatsCard(BuildContext context, Pet pet, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.orangePrimary.withOpacity(0.2),
                  child: Icon(
                    pet.species.toLowerCase() == 'dog'
                        ? Icons.pets_rounded
                        : pet.species.toLowerCase() == 'cat'
                        ? Icons.catching_pokemon_rounded
                        : Icons.flutter_dash_rounded,
                    color: AppTheme.orangePrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PetProfileScreen(pet: pet),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${pet.breed} • ${pet.species.toUpperCase()}',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Age', '${pet.age} yrs', Icons.cake_rounded),
                _buildStatItem(
                  'Weight',
                  '${pet.weight} kg',
                  Icons.fitness_center_rounded,
                ),
                _buildStatItem(
                  'Checklist',
                  '${pet.checklist.where((c) => c.isDone).length}/${pet.checklist.length}',
                  Icons.rule_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.tealSecondary, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMilestonesProgress(
    BuildContext context,
    Pet pet,
    int completed,
    int total,
    double progress,
    bool isDark,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ChecklistScreen()));
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Parent Checklist Progress',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: AppTheme.orangeDeep,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: isDark
                      ? const Color(0xFF444444)
                      : Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.tealSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Milestones: $completed completed out of $total. Tap to tick off remaining!',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardReminders(
    BuildContext context,
    AppState state,
    bool isDark,
  ) {
    final pendingReminders = state.reminders.where((r) => !r.isDone).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Smart Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReminderScreen()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppTheme.tealSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (pendingReminders.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No pending reminders for ${state.selectedPet!.name}. All caught up!',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ),
          )
        else
          ...pendingReminders
              .take(3)
              .map((r) => _buildReminderRow(context, state, r, isDark)),
      ],
    );
  }

  Widget _buildReminderRow(
    BuildContext context,
    AppState state,
    PetReminder r,
    bool isDark,
  ) {
    final isOverdue = r.dateTime.isBefore(DateTime.now());

    // Choose icon depending on reminder type
    final typeIcon = r.type.toLowerCase() == 'vaccine'
        ? Icons.vaccines_rounded
        : r.type.toLowerCase() == 'medicine'
        ? Icons.medication_rounded
        : r.type.toLowerCase() == 'grooming'
        ? Icons.content_cut_rounded
        : Icons.restaurant_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOverdue
              ? Colors.redAccent.withOpacity(0.12)
              : AppTheme.tealSecondary.withOpacity(0.12),
          child: Icon(
            typeIcon,
            color: isOverdue ? Colors.redAccent : AppTheme.tealSecondary,
          ),
        ),
        title: Text(
          r.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'Date: ${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year} - '
          '${r.dateTime.hour.toString().padLeft(2, '0')}:${r.dateTime.minute.toString().padLeft(2, '0')}'
          '${isOverdue ? " (Overdue!)" : ""}',
          style: TextStyle(
            color: isOverdue
                ? Colors.redAccent
                : (isDark ? Colors.white60 : Colors.black54),
            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        trailing: Checkbox(
          value: r.isDone,
          activeColor: AppTheme.tealSecondary,
          onChanged: (val) {
            if (val != null) {
              state.toggleReminderDone(r.id, val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.45,
      children: [
        _buildGridItem(
          context,
          title: 'Pet Encyclopedia',
          icon: Icons.menu_book_rounded,
          color: Colors.amber,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EncyclopediaScreen())),
        ),
        _buildGridItem(
          context,
          title: 'Symptom Advisor',
          icon: Icons.personal_injury_rounded,
          color: Colors.redAccent,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AdvisoryScreen())),
        ),
        _buildGridItem(
          context,
          title: 'Behavior Log',
          icon: Icons.bar_chart_rounded,
          color: AppTheme.orangePrimary,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const BehaviourScreen())),
        ),
        _buildGridItem(
          context,
          title: 'Health Wallet',
          icon: Icons.folder_shared_rounded,
          color: AppTheme.tealSecondary,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const HealthWalletScreen())),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF3E2723),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
