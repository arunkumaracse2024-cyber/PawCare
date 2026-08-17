
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'state/encyclopedia_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/shared/onboarding_screen.dart';
import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/shop/shop_dashboard_screen.dart';
import 'screens/vet/vet_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EncyclopediaProvider()..loadData(),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<EncyclopediaProvider, AppState>(
          create: (_) => AppState(),
          update: (_, ency, state) => state!..updateEncyclopedia(ency),
        ),
      ],
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
          home: _getHomeScreen(state),
        );
      },
    );
  }

  Widget _getHomeScreen(AppState state) {
    if (state.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Auth-Check state routing
    if (!state.isAuthenticated) {
      return const AuthScreen();
    }

    final user = state.currentUser!;
    if (!user.hasCompletedOnboarding && user.role == 'owner') {
      return const OnboardingScreen();
    }

    if (user.role == 'shop') {
      return const ShopDashboardScreen();
    } else if (user.role == 'vet') {
      return const VetDashboardScreen();
    } else {
      return const OwnerDashboardScreen();
    }
  }
}




