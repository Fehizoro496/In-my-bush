/// Compile-time configuration, injected with `--dart-define`.
///
/// ```sh
/// flutter run --dart-define=API_URL=http://10.0.2.2:8080/api/v1 --dart-define=USE_MOCK=false
/// ```
abstract class AppConfig {
  /// Base URL of the Spring Boot API (`/api/v1`).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  /// When `true` (default) every repository returns the mockup data locally.
  static const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  static const String appName = 'In my bush';
  static const String version = '1.0';
}
