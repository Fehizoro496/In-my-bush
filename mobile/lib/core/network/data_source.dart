import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

/// Switches every repository between the REST implementation (default) and
/// the mock implementation (mockup data).
///
/// Override it in tests or from `--dart-define=USE_MOCK=true`.
final useMockDataProvider = Provider<bool>((ref) => AppConfig.useMock);

/// Simulated network latency of the mock repositories (zero in tests).
abstract class MockLatency {
  static Duration duration = const Duration(milliseconds: 350);

  static Future<void> wait([Duration? override]) =>
      Future<void>.delayed(override ?? duration);
}
