import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../auth_screen.dart';
import 'clinic_profile_screen.dart';
import 'manage_slots_screen.dart';
import 'appointment_requests_screen.dart';
import '../shared/future_scope_screen.dart';

class VetDashboardScreen extends StatelessWidget {
  const VetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    final incomingRequests = state.appointments.where((a) => a.status == 'pending').toList();
    final activeSlots = state.timeSlots.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vet Clinic Dashboard"),
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
            // Clinic Welcome Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.tealSecondary, AppTheme.tealDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.currentVetProfile?.clinicName ?? "Welcome Doctor",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (state.currentVetProfile?.isVerified ?? false)
                        const Icon(Icons.verified_rounded, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.currentVetProfile?.specialization ?? "General Veterinary Practitioner",
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
                    title: "Incoming Tokens",
                    value: "${incomingRequests.length}",
                    icon: Icons.notifications_active_rounded,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: "Active Slots",
                    value: "$activeSlots",
                    icon: Icons.calendar_month_rounded,
                    color: AppTheme.tealSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: "Partnered Shops",
                    value: "${state.currentVetProfile?.partnerShopIds.length ?? 0}",
                    icon: Icons.store_rounded,
                    color: AppTheme.orangePrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Clinic Admin Actions",
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
                  title: "Appointments",
                  description: "Manage incoming token requests",
                  icon: Icons.calendar_today_rounded,
                  color: Colors.amber,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppointmentRequestsScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: "Manage Slots",
                  description: "Define calendar availability",
                  icon: Icons.access_time_rounded,
                  color: AppTheme.tealSecondary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageSlotsScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: "Clinic Profile",
                  description: "Edit clinic details & specialty",
                  icon: Icons.local_hospital_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ClinicProfileScreen()),
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

