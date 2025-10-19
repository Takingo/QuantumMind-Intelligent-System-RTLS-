import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quantummind_rtls/main.dart';
import 'package:quantummind_rtls/app.dart';

void main() {
  testWidgets('QuantumMind app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuantumMindApp());

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
