// Marginal Gains App - Widget Tests
import 'package:flutter_test/flutter_test.dart';

import 'package:centile/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarginalGainsApp());

    // Give initial async state time to load without waiting for intentional
    // repeating animations to "settle" forever.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Smoke test: the app root widget is present.
    expect(find.byType(MarginalGainsApp), findsOneWidget);
  });
}
