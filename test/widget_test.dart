// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:petpaw/main.dart';
import 'package:petpaw/state/app_state.dart';

void main() {
  testWidgets('PawCareApp onboarding test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const PawCareApp(),
      ),
    );
    // Pump first frame
    await tester.pump();

    // Programmatically pump while the app is loading to avoid infinite progress indicator timeouts
    final context = tester.element(find.byType(PawCareApp));
    final AppState state = Provider.of<AppState>(context, listen: false);
    while (state.isLoading) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    // Re-render once loading is complete
    await tester.pump();

    // Verify that our auth screen Log In button is shown.
    expect(find.text('Log In'), findsWidgets);
  });
}
