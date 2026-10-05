import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints/endpoints.dart';
import '../../../core/network/token_storage.dart';
import '../../../core/utils/json.dart';
import '../../account/data/account_repository.dart';
import '../../account/data/models/models.dart';

abstract class AuthRepository {
  /// Restores the session (null = signed out).
  Future<AppUser?> restore();

  Future<AppUser> login({required String phone, required String password});

  Future<AppUser> register({required String fullName, required String phone, required String password});

  Future<void> requestOtp(String phone);

  Future<AppUser> verifyOtp({required String phone, required String code});

  Future<void> logout();
}

/// Normalises "34 00 000 00" → "+261340000000".
String normalizePhone(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('261')) return '+$digits';
  if (digits.startsWith('0')) return '+261${digits.substring(1)}';
  return '+261$digits';
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<AppUser?> restore() async => AccountMockData.hery;

  @override
  Future<AppUser> login({required String phone, required String password}) async {
    await MockLatency.wait();
    return AccountMockData.hery;
  }

  @override
  Future<AppUser> register({required String fullName, required String phone, required String password}) async {
    await MockLatency.wait();
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return AppUser(
      id: 'user-new',
      firstName: parts.isEmpty ? '' : parts.first,
      lastName: parts.length > 1 ? parts.skip(1).join(' ') : '',
      phone: normalizePhone(phone),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> requestOtp(String phone) => MockLatency.wait();

  @override
  Future<AppUser> verifyOtp({required String phone, required String code}) async {
    await MockLatency.wait();
    return AccountMockData.hery;
  }

  @override
  Future<void> logout() => MockLatency.wait();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._tokens, this._account);

  final ApiClient _api;
  final TokenStorage _tokens;
  final AccountRepository _account;

  Future<AppUser> _session(dynamic data) async {
    final json = readMap(data);
    await _tokens.save(
      accessToken: readString(json['accessToken']),
      refreshToken: readStringOrNull(json['refreshToken']),
    );
    return _account.getMe();
  }

  @override
  Future<AppUser?> restore() async {
    final token = await _tokens.readAccessToken();
    if (token == null) return null;
    try {
      return await _account.getMe();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> login({required String phone, required String password}) async =>
      _session(await _api.post(AuthEndpoints.login, body: {'identifier': normalizePhone(phone), 'password': password}));

  @override
  Future<AppUser> register({required String fullName, required String phone, required String password}) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return _session(await _api.post(AuthEndpoints.register, body: {
      'firstName': parts.first,
      'lastName': parts.skip(1).join(' '),
      'phone': normalizePhone(phone),
      'password': password,
    }));
  }

  @override
  Future<void> requestOtp(String phone) async => _api.post(AuthEndpoints.otpRequest, body: {'phone': normalizePhone(phone)});

  @override
  Future<AppUser> verifyOtp({required String phone, required String code}) async {
    final json = readMap(await _api.post(AuthEndpoints.otpVerify, body: {'phone': normalizePhone(phone), 'code': code}));
    // `auth` is only present when an account already exists for this phone.
    if (json['auth'] is! Map) {
      throw const ApiException(title: 'Compte introuvable', detail: 'Aucun compte n’est associé à ce numéro.');
    }
    return _session(json['auth']);
  }

  @override
  Future<void> logout() async {
    final refresh = await _tokens.readRefreshToken();
    try {
      await _api.post(AuthEndpoints.logout, body: {'refreshToken': refresh});
    } finally {
      await _tokens.clear();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockAuthRepository();
  return ApiAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
    ref.watch(accountRepositoryProvider),
  );
});
