import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../account/data/account_repository.dart';
import '../account/data/models/models.dart';
import 'data/auth_repository.dart';

/// Current session: `AsyncData(null)` = signed out.
class AuthController extends AsyncNotifier<AppUser?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AppUser?> build() => ref.watch(authRepositoryProvider).restore();

  Future<void> login(String phone, String password) async {
    state = const AsyncLoading<AppUser?>();
    state = await AsyncValue.guard(() => _repo.login(phone: phone, password: password));
    _sessionChanged();
  }

  Future<void> register(String fullName, String phone, String password) async {
    state = const AsyncLoading<AppUser?>();
    state = await AsyncValue.guard(() => _repo.register(fullName: fullName, phone: phone, password: password));
    _sessionChanged();
  }

  Future<void> requestOtp(String phone) => _repo.requestOtp(phone);

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData<AppUser?>(null);
    _sessionChanged();
  }

  /// Reloads the user-scoped data (cart, orders, messages…).
  void _sessionChanged() => ref.read(sessionEpochProvider.notifier).state++;

  Future<void> updateProfile({String? fullName, String? email, String? city}) async {
    final user = await ref.read(accountRepositoryProvider).updateMe(fullName: fullName, email: email, city: city);
    state = AsyncData<AppUser?>(user);
  }

  /// After "Ouvrir ma boutique".
  void becameSeller(String shopName, {String? shopSlug}) {
    final user = state.valueOrNull;
    if (user == null) return;
    state = AsyncData<AppUser?>(
      user.copyWith(roles: {...user.roles, UserRole.seller}, shopName: shopName, shopSlug: shopSlug),
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

final currentUserProvider = Provider<AppUser?>((ref) => ref.watch(authControllerProvider).valueOrNull);
