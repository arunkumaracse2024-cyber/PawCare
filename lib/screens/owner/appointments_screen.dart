import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/appointment.dart';
import '../../models/vet_profile.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Appointments"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Past / Completed"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveTab(context, state, isDark),
            _buildPastTab(context, state, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context, AppState state, bool isDark) {
    final active = state.appointments
        .where((a) => a.status == 'pending' || a.status == 'accepted')
        .toList();

    if (active.isEmpty) {
      return const Center(child: Text("No active appointments."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: active.length,
      itemBuilder: (context, index) {
        final appt = active[index];
        return _buildAppointmentCard(context, state, appt, isDark);
      },
    );
  }

  Widget _buildPastTab(BuildContext context, AppState state, bool isDark) {
    final past = state.appointments
        .where((a) => a.status == 'completed' || a.status == 'rejected' || a.status == 'cancelled')
        .toList();

    if (past.isEmpty) {
      return const Center(child: Text("No past appointments."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: past.length,
      itemBuilder: (context, index) {
        final appt = past[index];
        return _buildAppointmentCard(context, state, appt, isDark);
      },
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppState state,
    Appointment appt,
    bool isDark,
  ) {
    final vet = state.allVets.firstWhere(
      (v) => v.uid == appt.vetUid,
      orElse: () => VetProfile(
        uid: appt.vetUid,
        clinicName: "Clinic Name",
        address: "Address",
        specialization: "General",
        workingHours: {},
        isVerified: false,
        partnerShopIds: [],
      ),
    );

    // Status color mapping
    Color getStatusColor() {
      switch (appt.status) {
        case 'accepted':
          return Colors.green;
        case 'rejected':
        case 'cancelled':
          return Colors.redAccent;
        case 'completed':
          return Colors.blue;
        case 'pending':
        default:
          return Colors.amber;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vet.clinicName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appt.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Date: ${appt.dateTime.day}/${appt.dateTime.month}/${appt.dateTime.year} at ${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text("Notes: ${appt.notes}"),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(),
            ),
            if (appt.status == 'pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Cancel Appointment"),
                          content: const Text("Are you sure you want to cancel this appointment request?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await state.updateAppointmentStatus(appt.id, 'cancelled');
                      }
                    },
                    icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                    label: const Text("Cancel Booking", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ] else if (appt.status == 'completed') ...[
              const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                  SizedBox(width: 6),
                  Text("Visit notes saved in pet Health Wallet", style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic)),
                ],
              ),
            ] else ...[
              const Text("No active actions for this status.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}

