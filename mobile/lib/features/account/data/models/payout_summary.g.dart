// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayoutSummary _$PayoutSummaryFromJson(Map<String, dynamic> json) =>
    PayoutSummary(
      nextAmount: parseInt(json['nextAmount']),
      nextDate: parseDateOrNow(json['nextDate']),
      destination: parseString(json['destination']),
    );
