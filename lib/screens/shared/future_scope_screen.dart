import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FutureScopeScreen extends StatelessWidget {
  const FutureScopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> features = [
      {
        'title': 'In-App Payments',
        'desc': 'Direct payment gateway integration for shop purchases, vet consultations and vaccine purchases. All payments are currently handled offline in person.',
        'icon': Icons.payment_rounded,
      },
      {
        'title': 'Commission & Earnings Dashboard',
        'desc': 'Commission tracking models, referral payouts, and admin earnings tracking interfaces for partnered pet shops.',
        'icon': Icons.dashboard_customize_rounded,
      },
      {
        'title': 'Real Veterinary License KYC',
        'desc': 'Official government registry verification checks, veterinary license document upload and KYC automated approvals.',
        'icon': Icons.verified_user_rounded,
      },
      {
        'title': 'Home-Visit Scheduling',
        'desc': 'Doctor home visit dispatch, real-time map tracking, live location coordinates sharing and mileage calculations.',
        'icon': Icons.home_work_rounded,
      },
      {
        'title': 'SMS & Call Reminders',
        'desc': 'Direct telephony carrier reminders, emergency SMS text triggers, and telephone follow-up automation integrations.',
        'icon': Icons.sms_rounded,
      },
      {
        'title': 'Doctor Ratings & Reviews',
        'desc': 'Stars rating feedback, detailed client reviews, doctor sorting by average ratings, and clinic verification comments.',
        'icon': Icons.rate_review_rounded,
      },
      {
        'title': 'Emergency Priority Tokens',
        'desc': 'Instant triage emergency queues bypassing standard slot bookings for active critical trauma cases.',
        'icon': Icons.emergency_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("V2 Future Scope Roadmap"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.tealSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.tealSecondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: AppTheme.tealSecondary, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    "The features listed below are explicitly out of scope for the current PawCare Connect build. Offline workflows are assumed.",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...features.map((feat) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.orangePrimary.withValues(alpha: 0.12),
                  child: Icon(feat['icon'] as IconData, color: AppTheme.orangePrimary),
                ),
                title: Text(
                  feat['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(feat['desc'] as String),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

