// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesHistory _$SalesHistoryFromJson(Map<String, dynamic> json) => SalesHistory(
  gross: parseInt(json['gross']),
  commission: parseInt(json['commission']),
  net: parseInt(json['net']),
  bars: (json['bars'] as List<dynamic>)
      .map((e) => SalesBar.fromJson(e as Map<String, dynamic>))
      .toList(),
  records: (json['records'] as List<dynamic>)
      .map((e) => SaleRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
);
