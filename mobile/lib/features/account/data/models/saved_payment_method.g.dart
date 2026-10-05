// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedPaymentMethod _$SavedPaymentMethodFromJson(Map<String, dynamic> json) =>
    SavedPaymentMethod(
      id: parseString(json['id']),
      method:
          $enumDecodeNullable(
            _$PaymentMethodEnumMap,
            json['method'],
            unknownValue: PaymentMethod.mvola,
          ) ??
          PaymentMethod.mvola,
      label: parseString(_readPaymentLabel(json, 'label')),
      detail: parseString(_readPaymentDetail(json, 'detail')),
      isDefault: json['isDefault'] == null
          ? false
          : parseBool(json['isDefault']),
    );

Map<String, dynamic> _$SavedPaymentMethodToJson(SavedPaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'label': instance.label,
      'detail': instance.detail,
      'isDefault': instance.isDefault,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.mvola: 'MVOLA',
  PaymentMethod.orangeMoney: 'ORANGE_MONEY',
  PaymentMethod.airtelMoney: 'AIRTEL_MONEY',
  PaymentMethod.card: 'CARD',
  PaymentMethod.cashOnDelivery: 'CASH_ON_DELIVERY',
};
