import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';

enum SalesPeriod {
  week('7 j'),
  month('30 j'),
  halfYear('6 mois'),
  year('12 mois');

  const SalesPeriod(this.label);

  final String label;
}

class SalesBar {
  const SalesBar({required this.label, required this.value, this.valueLabel});

  final String label;

  /// Amount in Ariary.
  final int value;

  /// "1,24" (millions) on the history chart.
  final String? valueLabel;
}

class SellerDashboard {
  const SellerDashboard({
    required this.revenue,
    required this.trendPercent,
    required this.bars,
    required this.ordersReceived,
    required this.toPrepare,
    required this.activeProducts,
    required this.drafts,
    required this.lowStock,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory SellerDashboard.fromJson(JsonMap json) => SellerDashboard(
        revenue: readInt(json['revenue']),
        trendPercent: readDouble(json['trendPercent']),
        bars: readList(json['bars'], (b) => SalesBar(label: readString(b['label']), value: readInt(b['value']))),
        ordersReceived: readInt(json['ordersReceived']),
        toPrepare: readInt(json['toPrepare']),
        activeProducts: readInt(json['activeProducts']),
        drafts: readInt(json['drafts']),
        lowStock: readInt(json['lowStock']),
        ratingAvg: readDouble(json['ratingAvg']),
        ratingCount: readInt(json['ratingCount']),
      );

  final int revenue;
  final double trendPercent;
  final List<SalesBar> bars;
  final int ordersReceived;
  final int toPrepare;
  final int activeProducts;
  final int drafts;
  final int lowStock;
  final double ratingAvg;
  final int ratingCount;
}

enum PayoutState {
  paid('Versé'),
  pending('En attente'),
  refunded('Remboursé');

  const PayoutState(this.label);

  final String label;

  static PayoutState fromPaymentStatus(Object? v) {
    if (v == 'RELEASED') return PayoutState.paid;
    if (v == 'REFUNDED') return PayoutState.refunded;
    return PayoutState.pending;
  }
}

/// One line of "Historique des ventes".
class SaleRecord {
  const SaleRecord({
    required this.orderId,
    required this.number,
    required this.client,
    required this.itemsSummary,
    required this.amount,
    required this.payout,
    required this.date,
    this.visual = const Visual(),
  });

  factory SaleRecord.fromJson(JsonMap json) => SaleRecord(
        orderId: readString(json['orderId']),
        number: readString(json['number']),
        client: readString(json['client']),
        itemsSummary: readString(json['itemsSummary']),
        amount: readInt(json['amount']),
        payout: PayoutState.fromPaymentStatus(json['paymentStatus']),
        date: readDate(json['date']) ?? DateTime.now(),
        visual: json['visual'] is Map ? Visual.fromJson(readMap(json['visual'])) : const Visual(),
      );

  final String orderId;
  final String number;
  final String client;
  final String itemsSummary;
  final int amount;
  final PayoutState payout;
  final DateTime date;
  final Visual visual;
}

class SalesHistory {
  const SalesHistory({
    required this.gross,
    required this.commission,
    required this.net,
    required this.bars,
    required this.records,
  });

  final int gross;
  final int commission;
  final int net;
  final List<SalesBar> bars;
  final List<SaleRecord> records;
}

/// Draft of the add / edit product form.
class ProductDraft {
  const ProductDraft({
    this.id,
    this.name = '',
    this.categoryPath = '',
    this.description = '',
    this.price,
    this.unitLabel = 'Botte',
    this.stock,
    this.lowStockThreshold,
    this.origin = '',
    this.homeDelivery = true,
    this.pickup = true,
    this.nationalShipping = false,
    this.visible = true,
  });

  final String? id;
  final String name;
  final String categoryPath;
  final String description;
  final int? price;
  final String unitLabel;
  final int? stock;
  final int? lowStockThreshold;
  final String origin;
  final bool homeDelivery;
  final bool pickup;
  final bool nationalShipping;
  final bool visible;

  JsonMap toJson() => compactJson({
        'name': name,
        'categoryPath': categoryPath,
        'description': description,
        'price': price,
        'unitLabel': unitLabel,
        'stock': stock,
        'lowStockThreshold': lowStockThreshold,
        'originRegion': origin,
        'deliveryOptions': [
          if (homeDelivery) 'HOME',
          if (pickup) 'PICKUP',
          if (nationalShipping) 'NATIONAL',
        ],
        'visible': visible,
      });
}

/// Editable shop profile (Ma boutique).
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

  JsonMap toJson() => {
        'name': name,
        'description': description,
        'city': location,
        'pickupDays': pickupDays.toList(),
        'pickupFrom': pickupFrom,
        'pickupTo': pickupTo,
        'deliveryZones': zones,
        'deliveryFee': deliveryFee,
        'status': paused ? 'PAUSED' : 'ACTIVE',
      };
}
