// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerDashboard _$SellerDashboardFromJson(Map<String, dynamic> json) =>
    SellerDashboard(
      revenue: parseInt(json['revenue']),
      trendPercent: parseDouble(json['trendPercent']),
      bars: (json['bars'] as List<dynamic>)
          .map((e) => SalesBar.fromJson(e as Map<String, dynamic>))
          .toList(),
      ordersReceived: parseInt(json['ordersReceived']),
      toPrepare: parseInt(json['toPrepare']),
      activeProducts: parseInt(json['activeProducts']),
      drafts: parseInt(json['drafts']),
      lowStock: parseInt(json['lowStock']),
      ratingAvg: parseDouble(json['ratingAvg']),
      ratingCount: parseInt(json['ratingCount']),
    );
