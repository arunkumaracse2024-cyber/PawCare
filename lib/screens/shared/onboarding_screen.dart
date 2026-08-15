import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../owner/owner_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _screens = [
    OnboardingData(
      title: 'Complete Pet Dashboard',
      description:
          'Detail pet statistics, health reminders, vaccination milestones, and daily behaviour logs in one place.',
      icon: Icons.dashboard_rounded,
      color: AppTheme.orangePrimary,
    ),
    OnboardingData(
      title: 'Smart Reminders',
      description:
          'Get notified for vaccines, medicine doses, and grooming appointments on time.',
      icon: Icons.notifications_active_rounded,
      color: AppTheme.tealSecondary,
    ),
    OnboardingData(
      title: 'Pet Encyclopedia & Advisory',
      description:
          'Verify safe/unsafe foods instantly and consult the symptom advisory logic offline.',
      icon: Icons.menu_book_rounded,
      color: Colors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _finishOnboarding(),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _screens.length,
                itemBuilder: (context, index) {
                  final item = _screens[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, size: 100, color: item.color),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF3E2723),
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _screens.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.orangePrimary
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _screens.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.completeOnboarding();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
      );
    }
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
