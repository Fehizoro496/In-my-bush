import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';

part 'shop_settings.g.dart';

/// Editable shop profile (Ma boutique).
@JsonSerializable(createFactory: false)
class ShopSettings {
  const ShopSettings({
    required this.name,
    required this.description,
    required this.location,
    required this.pickupDays,
    required this.pickupFrom,
    required this.pickupTo,
    required this.zones,
    this.deliveryFee = 3000,
    this.paused = false,
  });

  final String name;
  final String description;
  final String location;
  final Set<String> pickupDays;
  final String pickupFrom;
  final String pickupTo;
  final List<String> zones;
  final int deliveryFee;
  final bool paused;

  ShopSettings copyWith({Set<String>? pickupDays, List<String>? zones, bool? paused}) => ShopSettings(
        name: name,
        description: description,
        location: location,
        pickupDays: pickupDays ?? this.pickupDays,
        pickupFrom: pickupFrom,
        pickupTo: pickupTo,
        zones: zones ?? this.zones,
        deliveryFee: deliveryFee,
        paused: paused ?? this.paused,
      );

  JsonMap toJson() => _$ShopSettingsToJson(this);
}
