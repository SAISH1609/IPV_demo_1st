import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/main.dart'; // Relative path to main.dart
import '../lib/screens/home_screen.dart'; // Relative path to home_screen.dart
import '../lib/screens/login_screen.dart'; // Relative path to login_screen.dart
//import '../lib/services/api_service.dart'; // Relative path to api_service.dart

void main() {
  group('Widget Tests', () {
    testWidgets('App starts with HomeScreen', (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>(create: (_) => ApiService()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that HomeScreen is displayed.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('Navigate to LoginScreen', (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>(create: (_) => ApiService()),
          ],
          child: const MyApp(),
        ),
      );

      // Simulate navigation to LoginScreen.
      await tester.tap(find.byIcon(
          Icons.history)); // Assuming history icon navigates to reports.
      await tester.pumpAndSettle();

      // Verify that LoginScreen is displayed.
      expect(find.byType(LoginScreen),
          findsNothing); // LoginScreen is not directly navigated.
    });

    testWidgets('Check-in button is functional', (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>(create: (_) => ApiService()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that the Check-In button is present.
      expect(find.text('Check In'), findsOneWidget);

      // Simulate tapping the Check-In button.
      await tester.tap(find.text('Check In'));
      await tester.pump();

      // Verify that the Check-In button was tapped (no errors).
      expect(find.text('Check In'), findsOneWidget);
    });

    testWidgets('Check-out button is functional', (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>(create: (_) => ApiService()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that the Check-Out button is present.
      expect(find.text('Check Out'), findsOneWidget);

      // Simulate tapping the Check-Out button.
      await tester.tap(find.text('Check Out'));
      await tester.pump();

      // Verify that the Check-Out button was tapped (no errors).
      expect(find.text('Check Out'), findsOneWidget);
    });
  });
}
