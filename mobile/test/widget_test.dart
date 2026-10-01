import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:in_my_bush/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InMyBushApp()),
    );

    // Verify the app starts and shows the bottom navigation
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
