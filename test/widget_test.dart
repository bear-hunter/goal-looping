// Marginal Gains App - Widget Tests
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:centile/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarginalGainsApp());

    // Verify that the app launches with the Home screen
    expect(find.text('Today\'s Focus'), findsOneWidget);
  });
}
