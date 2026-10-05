import 'package:json_annotation/json_annotation.dart';

import '../../../../shared/widgets/badges.dart' show StatusTone;

/// `orders.status` — PENDING_CONFIRMATION → ACCEPTED → PREPARED →
/// IN_DELIVERY → DELIVERED, exits REFUSED / CANCELLED.
@JsonEnum(valueField: 'apiName')
enum OrderStatus {
  pendingConfirmation('PENDING_CONFIRMATION', 'En attente', 'À confirmer', 'Nouvelle'),
  accepted('ACCEPTED', 'En préparation', 'À préparer', 'Acceptée'),
  prepared('PREPARED', 'Préparée', 'Préparée', 'Préparée'),
  inDelivery('IN_DELIVERY', 'En route', 'En livraison', 'En livraison'),
  delivered('DELIVERED', 'Livrée', 'Terminée', 'Livrée'),
  refused('REFUSED', 'Refusée', 'Refusée', 'Refusée'),
  cancelled('CANCELLED', 'Annulée', 'Annulée', 'Annulée');

  const OrderStatus(this.apiName, this.buyerLabel, this.sellerLabel, this.sellerDetailLabel);

  final String apiName;
  final String buyerLabel;

  /// Label in the seller's list ("À confirmer", "À préparer"…).
  final String sellerLabel;

  /// Label in the seller's order header ("Nouvelle", "Acceptée"…).
  final String sellerDetailLabel;

  static OrderStatus fromApi(Object? value) =>
      OrderStatus.values.firstWhere((s) => s.apiName == value, orElse: () => OrderStatus.pendingConfirmation);

  /// Position in the happy path (0…4), -1 for refused / cancelled.
  int get step {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.prepared:
        return 2;
      case OrderStatus.inDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.refused:
      case OrderStatus.cancelled:
        return -1;
    }
  }

  static const List<OrderStatus> flow = [
    OrderStatus.pendingConfirmation,
    OrderStatus.accepted,
    OrderStatus.prepared,
    OrderStatus.inDelivery,
    OrderStatus.delivered,
  ];

  bool get isActive => step >= 0 && step < 4;
  bool get isClosed => !isActive;

  StatusTone get buyerTone {
    switch (this) {
      case OrderStatus.pendingConfirmation:
      case OrderStatus.accepted:
        return StatusTone.warning;
      case OrderStatus.prepared:
      case OrderStatus.inDelivery:
        return StatusTone.info;
      case OrderStatus.delivered:
        return StatusTone.success;
      case OrderStatus.refused:
      case OrderStatus.cancelled:
        return StatusTone.neutral;
    }
  }

  StatusTone get sellerTone {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return StatusTone.warning;
      case OrderStatus.accepted:
      case OrderStatus.prepared:
      case OrderStatus.inDelivery:
        return StatusTone.info;
      case OrderStatus.delivered:
        return StatusTone.success;
      case OrderStatus.refused:
      case OrderStatus.cancelled:
        return StatusTone.neutral;
    }
  }
}
