import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json.dart';
import '../../orders/data/order_models.dart' show PaymentMethod;
import 'account_models.dart';

abstract class AccountRepository {
  Future<AppUser> getMe();

  Future<AppUser> updateMe({String? fullName, String? email, String? city});

  Future<List<Address>> getAddresses();

  Future<Address> saveAddress(Address address);

  Future<void> deleteAddress(String id);

  Future<void> setDefaultAddress(String id);

  Future<List<SavedPaymentMethod>> getPaymentMethods();

  Future<void> setDefaultPaymentMethod(String id);

  Future<PayoutSummary> getPayoutSummary();
}

abstract class AccountMockData {
  static final AppUser hery = AppUser(
    id: 'user-hery',
    firstName: 'Hery',
    lastName: 'Rakoto',
    phone: '+261340000012',
    email: 'hery.r@example.mg',
    roles: const {UserRole.buyer, UserRole.seller},
    city: 'Antananarivo',
    district: 'Analakely',
    createdAt: DateTime(2024, 2, 10),
    phoneVerified: true,
    emailVerified: true,
    shopName: 'Le Jardin de Hery',
  );

  static List<Address> addresses() => const [
        Address(
          id: 'addr-home',
          label: 'Domicile',
          recipient: 'Hery Rakoto',
          phone: '+261 34 •• ••• 12',
          line1: 'Lot II A 45',
          district: 'Analakely',
          city: 'Antananarivo 101',
          landmark: 'portail vert en face de l’épicerie',
          isDefault: true,
        ),
        Address(
          id: 'addr-office',
          label: 'Bureau',
          recipient: 'Hery Rakoto',
          phone: '+261 34 •• ••• 12',
          line1: 'Immeuble Fitaratra',
          district: 'Ankorondrano',
          city: 'Antananarivo 101',
          landmark: 'immeuble blanc, 2e étage',
        ),
      ];
}

class MockAccountRepository implements AccountRepository {
  AppUser _me = AccountMockData.hery;
  List<Address> _addresses = AccountMockData.addresses();
  List<SavedPaymentMethod> _methods = const [
    SavedPaymentMethod(id: 'pm-mvola', method: PaymentMethod.mvola, label: 'MVola', detail: '+261 34 •• ••• 12', isDefault: true),
    SavedPaymentMethod(id: 'pm-visa', method: PaymentMethod.card, label: 'Carte Visa', detail: '•••• 4242 · exp. 08/28'),
  ];

  @override
  Future<AppUser> getMe() async {
    await MockLatency.wait();
    return _me;
  }

  @override
  Future<AppUser> updateMe({String? fullName, String? email, String? city}) async {
    await MockLatency.wait();
    String? first;
    String? last;
    if (fullName != null && fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      first = parts.first;
      last = parts.skip(1).join(' ');
    }
    return _me = _me.copyWith(firstName: first, lastName: last, email: email, city: city);
  }

  @override
  Future<List<Address>> getAddresses() async {
    await MockLatency.wait();
    return _addresses;
  }

  @override
  Future<Address> saveAddress(Address address) async {
    await MockLatency.wait();
    final saved = Address(
      id: address.id.isEmpty ? 'addr-${DateTime.now().millisecondsSinceEpoch}' : address.id,
      label: address.label,
      recipient: address.recipient.isEmpty ? _me.fullName : address.recipient,
      phone: address.phone.isEmpty ? _me.maskedPhone : address.phone,
      line1: address.line1,
      district: address.district,
      city: address.city,
      landmark: address.landmark,
      isDefault: _addresses.isEmpty,
    );
    _addresses = [..._addresses.where((a) => a.id != saved.id), saved];
    return saved;
  }

  @override
  Future<void> deleteAddress(String id) async {
    await MockLatency.wait();
    _addresses = _addresses.where((a) => a.id != id).toList();
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    _addresses = [for (final a in _addresses) a.copyWith(isDefault: a.id == id)];
  }

  @override
  Future<List<SavedPaymentMethod>> getPaymentMethods() async {
    await MockLatency.wait();
    return _methods;
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) async {
    _methods = [
      for (final m in _methods)
        SavedPaymentMethod(id: m.id, method: m.method, label: m.label, detail: m.detail, isDefault: m.id == id),
    ];
  }

  @override
  Future<PayoutSummary> getPayoutSummary() async {
    await MockLatency.wait();
    final now = DateTime.now();
    final thursday = now.add(Duration(days: (DateTime.thursday - now.weekday + 7) % 7));
    return PayoutSummary(nextAmount: 186400, nextDate: thursday, destination: 'MVola •• 12');
  }
}

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._api);

  final ApiClient _api;

  @override
  Future<AppUser> getMe() async => AppUser.fromJson(await _api.getMap('/me'));

  @override
  Future<AppUser> updateMe({String? fullName, String? email, String? city}) async {
    final body = <String, dynamic>{'email': email, 'city': city};
    if (fullName != null) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      body['firstName'] = parts.first;
      body['lastName'] = parts.skip(1).join(' ');
    }
    return AppUser.fromJson(readMap(await _api.patch('/me', body: compactJson(body))));
  }

  @override
  Future<List<Address>> getAddresses() async =>
      (await _api.getList('/me/addresses')).map((e) => Address.fromJson(readMap(e))).toList();

  @override
  Future<Address> saveAddress(Address address) async {
    final data = address.id.isEmpty
        ? await _api.post('/me/addresses', body: address.toJson())
        : await _api.patch('/me/addresses/${address.id}', body: address.toJson());
    return Address.fromJson(readMap(data));
  }

  @override
  Future<void> deleteAddress(String id) async => _api.delete('/me/addresses/$id');

  @override
  Future<void> setDefaultAddress(String id) async => _api.patch('/me/addresses/$id', body: {'isDefault': true});

  @override
  Future<List<SavedPaymentMethod>> getPaymentMethods() async =>
      (await _api.getList('/me/payout-methods')).map((e) => SavedPaymentMethod.fromJson(readMap(e))).toList();

  @override
  Future<void> setDefaultPaymentMethod(String id) async {}

  @override
  Future<PayoutSummary> getPayoutSummary() async {
    final payouts = await _api.getList('/seller/payouts', query: {'status': 'SCHEDULED', 'size': 1});
    if (payouts.isEmpty) {
      return PayoutSummary(nextAmount: 0, nextDate: DateTime.now(), destination: '');
    }
    final json = readMap(payouts.first);
    return PayoutSummary(
      nextAmount: readInt(json['amount']),
      nextDate: readDate(json['periodEnd']) ?? DateTime.now(),
      destination: readString(json['destination']),
    );
  }
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockAccountRepository();
  return ApiAccountRepository(ref.watch(apiClientProvider));
});

final addressesProvider = FutureProvider<List<Address>>((ref) => ref.watch(accountRepositoryProvider).getAddresses());

final paymentMethodsProvider =
    FutureProvider<List<SavedPaymentMethod>>((ref) => ref.watch(accountRepositoryProvider).getPaymentMethods());

final payoutSummaryProvider =
    FutureProvider<PayoutSummary>((ref) => ref.watch(accountRepositoryProvider).getPayoutSummary());
