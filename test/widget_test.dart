// Marginal Gains App - Widget Tests
import 'package:flutter_test/flutter_test.dart';

import 'package:centile/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarginalGainsApp());

    // Let initial async state (onboarding check, providers) settle.
    await tester.pumpAndSettle();

    // Smoke test: the app root widget is present.
    expect(find.byType(MarginalGainsApp), findsOneWidget);
  });
}
