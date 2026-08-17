import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/appointment.dart';
import '../../theme/app_theme.dart';
import 'visit_notes_screen.dart';

class AppointmentRequestsScreen extends StatelessWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pending = state.appointments.where((a) => a.status == 'pending').toList();
    final active = state.appointments.where((a) => a.status == 'accepted').toList();
    final past = state.appointments.where((a) => a.status == 'completed' || a.status == 'rejected' || a.status == 'cancelled').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Clinic Appointments"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Requests"),
              Tab(text: "Active Schedule"),
              Tab(text: "Past Visits"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, state, pending, isDark, true),
            _buildList(context, state, active, isDark, false),
            _buildList(context, state, past, isDark, false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AppState state, List<Appointment> list, bool isDark, bool isPendingTab) {
    if (list.isEmpty) {
      return const Center(child: Text("No appointments to display."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appt = list[index];
        return _buildAppointmentCard(context, state, appt, isDark, isPendingTab);
      },
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppState state,
    Appointment appt,
    bool isDark,
    bool isPendingTab,
  ) {
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
                  "Pet ID: ${appt.petId}",
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
            const SizedBox(height: 6),
            Text(
              "Slot: ${appt.dateTime.day}/${appt.dateTime.month}/${appt.dateTime.year} at ${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text("Owner Description / Reason: ${appt.notes}"),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(),
            ),

            if (appt.status == 'pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await state.updateAppointmentStatus(appt.id, 'rejected');
                    },
                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                    label: const Text("Decline", style: TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await state.updateAppointmentStatus(appt.id, 'accepted');
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text("Accept Slot"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tealSecondary),
                  ),
                ],
              ),
            ] else if (appt.status == 'accepted') ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VisitNotesScreen(appointment: appt),
                    ),
                  );
                },
                icon: const Icon(Icons.mode_edit_rounded),
                label: const Text("Complete Visit & Add Notes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.tealSecondary,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ] else ...[
              const Text("Archived appointment record.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}

