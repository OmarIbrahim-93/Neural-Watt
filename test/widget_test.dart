// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neural_watt/main.dart';
import 'package:neural_watt/login_screen.dart';
import 'package:neural_watt/home_screen.dart';
import 'package:neural_watt/utils/theme.dart';
import 'package:neural_watt/utils/theme_toggle_button.dart';

void main() {
  testWidgets('App renders LoginScreen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('App renders HomeScreen on Mobile test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Select Resource'), findsOneWidget);
  });

  testWidgets('App renders HomeScreen on Desktop test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Select Resource'), findsOneWidget);
  });

  testWidgets('App toggles theme mode when ThemeToggleButton is clicked', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(LoginScreen), findsOneWidget);

    // Initial theme check
    final initialMode = AppThemeNotifier.instance.value;
    
    // Find theme toggle button
    final toggleFinder = find.byType(ThemeToggleButton);
    expect(toggleFinder, findsOneWidget);

    // Tap toggle button
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    // Verify theme changed
    expect(AppThemeNotifier.instance.value, isNot(equals(initialMode)));
  });
}
