import '../../../core/utils/formatters.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../orders/data/order_models.dart' show PaymentMethod;

enum UserRole {
  buyer('BUYER'),
  seller('SELLER'),
  admin('ADMIN');

  const UserRole(this.apiName);

  final String apiName;

  static UserRole fromApi(Object? v) => UserRole.values.firstWhere((r) => r.apiName == v, orElse: () => UserRole.buyer);
}

class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.roles = const {UserRole.buyer},
    this.city = '',
    this.district = '',
    this.createdAt,
    this.phoneVerified = false,
    this.emailVerified = false,
    this.avatarColor = '#365A10',
    this.shopName,
  });

  factory AppUser.fromJson(JsonMap json) => AppUser(
        id: readString(json['id']),
        firstName: readString(json['firstName']),
        lastName: readString(json['lastName']),
        phone: readString(json['phone']),
        email: readStringOrNull(json['email']),
        avatarUrl: readStringOrNull(json['avatarUrl']),
        roles: readStringList(json['roles']).map(UserRole.fromApi).toSet(),
        city: readString(json['city']),
        district: readString(json['district']),
        createdAt: readDate(json['createdAt']),
        phoneVerified: readBool(json['phoneVerified']),
        emailVerified: readBool(json['emailVerified']),
        shopName: readStringOrNull(json['shopName']),
      );

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final Set<UserRole> roles;
  final String city;
  final String district;
  final DateTime? createdAt;
  final bool phoneVerified;
  final bool emailVerified;
  final String avatarColor;
  final String? shopName;

  String get fullName => '$firstName $lastName'.trim();
  String get initials => initialsOf(fullName);
  bool get isSeller => roles.contains(UserRole.seller);

  /// "Acheteur & vendeur · Analakely"
  String get roleLine => '${isSeller ? 'Acheteur & vendeur' : 'Acheteur'}${district.isEmpty ? '' : ' · $district'}';

  /// "+261 34 •• ••• 12"
  String get maskedPhone {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return phone;
    final local = digits.startsWith('261') ? digits.substring(3) : digits;
    final prefix = local.length >= 2 ? local.substring(0, 2) : local;
    return '+261 $prefix •• ••• ${local.substring(local.length - 2)}';
  }

  AppUser copyWith({String? firstName, String? lastName, String? email, String? city, Set<UserRole>? roles, String? shopName}) =>
      AppUser(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone,
        email: email ?? this.email,
        avatarUrl: avatarUrl,
        roles: roles ?? this.roles,
        city: city ?? this.city,
        district: district,
        createdAt: createdAt,
        phoneVerified: phoneVerified,
        emailVerified: emailVerified,
        avatarColor: avatarColor,
        shopName: shopName ?? this.shopName,
      );

  JsonMap toJson() => compactJson({
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'avatarUrl': avatarUrl,
        'roles': roles.map((r) => r.apiName).toList(),
        'city': city,
        'district': district,
        'createdAt': createdAt?.toUtc().toIso8601String(),
      });
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.line1,
    required this.district,
    required this.city,
    this.landmark = '',
    this.isDefault = false,
  });

  factory Address.fromJson(JsonMap json) => Address(
        id: readString(json['id']),
        label: readString(json['label'], 'Autre'),
        recipient: readString(json['recipient']),
        phone: readString(json['phone']),
        line1: readString(json['line1']),
        district: readString(json['district']),
        city: readString(json['city']),
        landmark: readString(json['landmark']),
        isDefault: readBool(json['isDefault']),
      );

  final String id;

  /// "Domicile", "Bureau", "Autre"
  final String label;
  final String recipient;
  final String phone;
  final String line1;
  final String district;
  final String city;
  final String landmark;
  final bool isDefault;

  String get icon => label == 'Domicile' ? 'home' : (label == 'Bureau' ? 'store' : 'pin');

  /// "[ADRESSE], Analakely, Antananarivo 101"
  String get fullLine => [line1, district, city].where((s) => s.isNotEmpty).join(', ');

  Address copyWith({bool? isDefault}) => Address(
        id: id,
        label: label,
        recipient: recipient,
        phone: phone,
        line1: line1,
        district: district,
        city: city,
        landmark: landmark,
        isDefault: isDefault ?? this.isDefault,
      );

  JsonMap toJson() => compactJson({
        'id': id.isEmpty ? null : id,
        'label': label,
        'recipient': recipient,
        'phone': phone,
        'line1': line1,
        'district': district,
        'city': city,
        'landmark': landmark,
        'isDefault': isDefault,
      });
}

/// Saved payment method (buyer) — Mobile Money wallet or card.
class SavedPaymentMethod {
  const SavedPaymentMethod({
    required this.id,
    required this.method,
    required this.label,
    required this.detail,
    this.isDefault = false,
  });

  factory SavedPaymentMethod.fromJson(JsonMap json) => SavedPaymentMethod(
        id: readString(json['id']),
        method: PaymentMethod.fromApi(json['method']),
        label: readString(json['label'], PaymentMethod.fromApi(json['method']).label),
        detail: readString(json['phoneMasked'] ?? json['detail']),
        isDefault: readBool(json['isDefault']),
      );

  final String id;
  final PaymentMethod method;
  final String label;

  /// "+261 34 •• ••• 12", "•••• 4242 · exp. 08/28"
  final String detail;
  final bool isDefault;

  Visual get look => method == PaymentMethod.card
      ? const Visual(tint: '#E8F1FA', ink: '#22527E', icon: 'card')
      : const Visual(tint: '#FFF4E8', ink: '#B4500A', icon: 'wallet');

  JsonMap toJson() => {'id': id, 'method': method.apiName, 'label': label, 'detail': detail, 'isDefault': isDefault};
}

/// Seller payout info ("Pour recevoir mes ventes").
class PayoutSummary {
  const PayoutSummary({required this.nextAmount, required this.nextDate, required this.destination});

  factory PayoutSummary.fromJson(JsonMap json) => PayoutSummary(
        nextAmount: readInt(json['nextAmount']),
        nextDate: readDate(json['nextDate']) ?? DateTime.now(),
        destination: readString(json['destination']),
      );

  final int nextAmount;
  final DateTime nextDate;

  /// "MVola •• 12"
  final String destination;
}
