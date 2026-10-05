// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CheckoutRequestToJson(CheckoutRequest instance) =>
    <String, dynamic>{
      'addressId': ?_emptyToNull(instance.addressId),
      'deliveryMode': _$DeliveryModeEnumMap[instance.deliveryMode]!,
      'deliverySlot': instance.slot,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'paymentPhone': ?instance.phone,
    };

const _$DeliveryModeEnumMap = {
  DeliveryMode.home: 'HOME',
  DeliveryMode.pickup: 'PICKUP',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.mvola: 'MVOLA',
  PaymentMethod.orangeMoney: 'ORANGE_MONEY',
  PaymentMethod.airtelMoney: 'AIRTEL_MONEY',
  PaymentMethod.card: 'CARD',
  PaymentMethod.cashOnDelivery: 'CASH_ON_DELIVERY',
};
