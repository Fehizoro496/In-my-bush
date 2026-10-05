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
}
