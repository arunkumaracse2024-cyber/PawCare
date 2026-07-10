import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'services/notification_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const PawCareApp(),
    ),
  );
}

class PawCareApp extends StatelessWidget {
  const PawCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'PawCare',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: NotificationOverlayWrapper(child: _getHomeScreen(state)),
        );
      },
    );
  }

  Widget _getHomeScreen(AppState state) {
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Auth-Check state routing
    if (state.currentUserEmail == null) {
      // Return onboarding screen on first load
      return const OnboardingScreen();
    }

    return const DashboardScreen();
  }
}

class NotificationOverlayWrapper extends StatefulWidget {
  final Widget child;
  const NotificationOverlayWrapper({super.key, required this.child});

  @override
  State<NotificationOverlayWrapper> createState() =>
      _NotificationOverlayWrapperState();
}

class _NotificationOverlayWrapperState
    extends State<NotificationOverlayWrapper> {
  StreamSubscription<NotificationPayload>? _subscription;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Start listening to simulation alerts
    _subscription = NotificationService().onNotificationTriggered.listen((
      payload,
    ) {
      _showInAppNotification(payload);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showInAppNotification(NotificationPayload payload) {
    if (!mounted) return;

    // Remove existing notification banner if currently shown
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child:
                Card(
                  color: isDark
                      ? const Color(0xFF332711)
                      : const Color(0xFFFFF3CD),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: Colors.amber.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.amber.withOpacity(0.2),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                payload.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                payload.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _overlayEntry?.remove();
                            _overlayEntry = null;
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(
                  begin: -1.2,
                  duration: 450.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Dismiss banner automatically after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (_overlayEntry != null && mounted) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
