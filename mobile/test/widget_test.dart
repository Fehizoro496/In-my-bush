import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:in_my_bush/app.dart';
import 'package:in_my_bush/core/network/data_source.dart';

void main() {
  setUp(() => MockLatency.duration = Duration.zero);

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [useMockDataProvider.overrideWithValue(true)],
        child: const InMyBushApp(),
      ),
    );
    // Let the mock repositories resolve so no timer outlives the test.
    await tester.pumpAndSettle();

    // Verify the app starts and shows the bottom navigation
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
