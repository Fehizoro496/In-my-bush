import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT pair in the platform keychain / keystore.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'imb.accessToken';
  static const _refreshKey = 'imb.refreshToken';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> save({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
