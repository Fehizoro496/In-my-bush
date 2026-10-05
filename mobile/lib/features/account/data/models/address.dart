import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';

part 'address.g.dart';

@JsonSerializable()
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

  factory Address.fromJson(JsonMap json) => _$AddressFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;

  /// "Domicile", "Bureau", "Autre"
  @JsonKey(defaultValue: 'Autre', fromJson: parseString)
  final String label;
  @JsonKey(fromJson: parseString)
  final String recipient;
  @JsonKey(fromJson: parseString)
  final String phone;
  @JsonKey(fromJson: parseString)
  final String line1;
  @JsonKey(fromJson: parseString)
  final String district;
  @JsonKey(fromJson: parseString)
  final String city;
  @JsonKey(fromJson: parseString)
  final String landmark;
  @JsonKey(fromJson: parseBool)
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

  JsonMap toJson() => _$AddressToJson(this);
}
