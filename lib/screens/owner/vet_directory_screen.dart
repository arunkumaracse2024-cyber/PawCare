import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/vet_profile.dart';
import '../../theme/app_theme.dart';
import 'book_appointment_screen.dart';

class VetDirectoryScreen extends StatelessWidget {
  const VetDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter vets linked to the shop of selected pet, or show all partnered vets
    List<VetProfile> getFilteredVets() {
      final pet = state.selectedPet;
      if (pet == null || pet.shopId == null || pet.shopId!.isEmpty) {
        return state.allVets; // Not shop-linked or no pet selected -> show all
      }

      // Filter vets that have this shopId in their partnerShopIds
      final filtered = state.allVets.where((vet) => vet.partnerShopIds.contains(pet.shopId)).toList();
      return filtered.isNotEmpty ? filtered : state.allVets;
    }

    final filteredVets = getFilteredVets();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Partnered Veterinarians"),
      ),
      body: filteredVets.isEmpty
          ? const Center(
              child: Text("No veterinarians registered in your network."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredVets.length,
              itemBuilder: (context, index) {
                final vet = filteredVets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.tealSecondary.withOpacity(0.12),
                              radius: 24,
                              child: const Icon(Icons.local_hospital_rounded, color: AppTheme.tealSecondary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        vet.clinicName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (vet.isVerified) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    vet.specialization,
                                    style: TextStyle(
                                      color: getSourceColor(vet.isVerified),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vet.address,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Hours: ${vet.workingHours.entries.map((e) => "${e.key}: ${e.value}").join(', ')}",
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookAppointmentScreen(vet: vet),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: const Text("Book Appointment Slot"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.tealSecondary,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color getSourceColor(bool verified) {
    return verified ? AppTheme.tealSecondary : Colors.amber;
  }
}
