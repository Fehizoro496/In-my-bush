import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

/// Switches every repository between the mock implementation (mockup data,
/// default) and the REST implementation.
///
/// Override it in tests or from `--dart-define=USE_MOCK=false`.
final useMockDataProvider = Provider<bool>((ref) => AppConfig.useMock);

/// Simulated network latency of the mock repositories (zero in tests).
abstract class MockLatency {
  static Duration duration = const Duration(milliseconds: 350);

  static Future<void> wait([Duration? override]) =>
      Future<void>.delayed(override ?? duration);
}
