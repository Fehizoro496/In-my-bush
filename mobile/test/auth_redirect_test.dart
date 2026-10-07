import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:in_my_bush/app.dart';
import 'package:in_my_bush/core/network/data_source.dart';
import 'package:in_my_bush/features/account/data/models/models.dart';
import 'package:in_my_bush/features/auth/data/auth_repository.dart';
import 'package:in_my_bush/features/auth/presentation/login_screen.dart';
import 'package:in_my_bush/features/catalog/presentation/home_screen.dart';

class _SignedOutAuthRepository extends MockAuthRepository {
  @override
  Future<AppUser?> restore() async => null;
}

void main() {
  setUp(() => MockLatency.duration = Duration.zero);

  Future<void> pumpApp(WidgetTester tester, {List<Override> overrides = const []}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [useMockDataProvider.overrideWithValue(true), ...overrides],
        child: const InMyBushApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('stays on the login screen without an authenticated user', (tester) async {
    await pumpApp(tester, overrides: [authRepositoryProvider.overrideWithValue(_SignedOutAuthRepository())]);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('opens the home screen with an authenticated user', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('sign-up fields do not share their text', (tester) async {
    await pumpApp(tester, overrides: [authRepositoryProvider.overrideWithValue(_SignedOutAuthRepository())]);

    await tester.tap(find.text('Inscription'));
    await tester.pumpAndSettle();

    // Name, phone, password.
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));
    await tester.enterText(fields.at(0), 'Hery Rakoto');
    await tester.enterText(fields.at(1), '34 12 345 67');
    await tester.pump();

    expect(tester.widget<TextField>(fields.at(0)).controller!.text, 'Hery Rakoto');
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, '34 12 345 67');
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, isEmpty);
  });

  testWidgets('sign-up asks for the SMS code before creating the account', (tester) async {
    await pumpApp(tester, overrides: [authRepositoryProvider.overrideWithValue(_SignedOutAuthRepository())]);

    await tester.tap(find.text('Inscription'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Hery Rakoto');
    await tester.enterText(fields.at(1), '34 12 345 67');
    await tester.enterText(fields.at(2), 'motdepasse');
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Still signed out: the code step replaces the form.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Code de vérification'), findsOneWidget);
    expect(find.text('Valider et créer mon compte'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.ensureVisible(find.text('Valider et créer mon compte'));
    await tester.tap(find.text('Valider et créer mon compte'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
