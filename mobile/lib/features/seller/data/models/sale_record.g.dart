// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleRecord _$SaleRecordFromJson(Map<String, dynamic> json) => SaleRecord(
  orderId: parseString(json['orderId']),
  number: parseString(json['number']),
  client: parseString(json['client']),
  itemsSummary: parseString(json['itemsSummary']),
  amount: parseInt(json['amount']),
  payout: PayoutState.fromPaymentStatus(json['paymentStatus']),
  date: parseDateOrNow(json['date']),
  visual: json['visual'] == null
      ? const Visual()
      : Visual.fromJson(json['visual'] as Map<String, dynamic>),
);
