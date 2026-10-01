import '../../../core/utils/formatters.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../../shared/widgets/badges.dart' show StatusTone;

/// `orders.status` — PENDING_CONFIRMATION → ACCEPTED → PREPARED →
/// IN_DELIVERY → DELIVERED, exits REFUSED / CANCELLED.
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

enum DeliveryMode {
  home('HOME', 'Livraison à domicile', 'Domicile'),
  pickup('PICKUP', 'Retrait chez les producteurs', 'Retrait');

  const DeliveryMode(this.apiName, this.label, this.shortLabel);

  final String apiName;
  final String label;
  final String shortLabel;

  static DeliveryMode fromApi(Object? value) =>
      DeliveryMode.values.firstWhere((m) => m.apiName == value, orElse: () => DeliveryMode.home);
}

/// `payments.method` (+ card, shown by the checkout mockup).
enum PaymentMethod {
  mvola('MVOLA', 'MVola'),
  orangeMoney('ORANGE_MONEY', 'Orange Money'),
  airtelMoney('AIRTEL_MONEY', 'Airtel Money'),
  card('CARD', 'Carte bancaire'),
  cashOnDelivery('CASH_ON_DELIVERY', 'Paiement à la réception');

  const PaymentMethod(this.apiName, this.label);

  final String apiName;
  final String label;

  bool get isMobileMoney =>
      this == PaymentMethod.mvola || this == PaymentMethod.orangeMoney || this == PaymentMethod.airtelMoney;

  /// "Mobile Money" for the three wallets.
  String get family => isMobileMoney ? 'Mobile Money' : label;

  static PaymentMethod fromApi(Object? value) =>
      PaymentMethod.values.firstWhere((m) => m.apiName == value, orElse: () => PaymentMethod.mvola);
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unitLabel,
    required this.quantity,
    this.visual = const Visual(),
    this.quantityLabel,
  });

  factory OrderItem.fromJson(JsonMap json) => OrderItem(
        id: readString(json['id']),
        productId: readString(json['productId']),
        productName: readString(json['productName']),
        unitPrice: readInt(json['unitPrice']),
        unitLabel: readString(json['unitLabel']),
        quantity: readInt(json['quantity'], 1),
        visual: json['visual'] is Map ? Visual.fromJson(readMap(json['visual'])) : const Visual(),
        quantityLabel: readStringOrNull(json['quantityLabel']),
      );

  final String id;
  final String productId;
  final String productName;
  final int unitPrice;
  final String unitLabel;
  final int quantity;
  final Visual visual;

  /// Custom quantity text ("1 kg", "2 bottes").
  final String? quantityLabel;

  int get lineTotal => unitPrice * quantity;

  /// "2 × 18 000 Ar"
  String get quantityText => quantityLabel ?? '$quantity × ${formatAriary(unitPrice)}';

  JsonMap toJson() => compactJson({
        'id': id,
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'unitLabel': unitLabel,
        'quantity': quantity,
        'lineTotal': lineTotal,
        'visual': visual.toJson(),
        'quantityLabel': quantityLabel,
      });
}

class OrderEvent {
  const OrderEvent({required this.status, required this.createdAt, this.note});

  factory OrderEvent.fromJson(JsonMap json) => OrderEvent(
        status: OrderStatus.fromApi(json['status']),
        note: readStringOrNull(json['note']),
        createdAt: readDate(json['createdAt']) ?? DateTime.now(),
      );

  final OrderStatus status;
  final String? note;
  final DateTime createdAt;

  JsonMap toJson() => compactJson({
        'status': status.apiName,
        'note': note,
        'createdAt': createdAt.toUtc().toIso8601String(),
      });
}

/// Counterpart summary (shop for the buyer, buyer for the seller).
class OrderParty {
  const OrderParty({required this.id, required this.name, required this.avatar, this.slug = '', this.meta});

  factory OrderParty.fromJson(JsonMap json) {
    final name = readString(json['name']);
    return OrderParty(
      id: readString(json['id']),
      name: name,
      slug: readString(json['slug']),
      avatar: json['avatar'] is Map
          ? AvatarLook.fromJson(readMap(json['avatar']))
          : AvatarLook(initials: initialsOf(name)),
      meta: readStringOrNull(json['meta']),
    );
  }

  final String id;
  final String name;
  final String slug;
  final AvatarLook avatar;

  /// "Cliente depuis 2025 · 6 commandes"
  final String? meta;

  JsonMap toJson() => compactJson({'id': id, 'name': name, 'slug': slug, 'avatar': avatar.toJson(), 'meta': meta});
}

class Courier {
  const Courier({required this.name, required this.avatar, this.vehicle = 'Moto', this.distance});

  factory Courier.fromJson(JsonMap json) => Courier(
        name: readString(json['name']),
        avatar: AvatarLook.fromJson(readMap(json['avatar'])),
        vehicle: readString(json['vehicle'], 'Moto'),
        distance: readStringOrNull(json['distance']),
      );

  final String name;
  final AvatarLook avatar;
  final String vehicle;
  final String? distance;

  JsonMap toJson() => compactJson({'name': name, 'avatar': avatar.toJson(), 'vehicle': vehicle, 'distance': distance});
}

/// One order = the part of a checkout prepared by one shop.
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.shop,
    required this.buyer,
    required this.status,
    required this.items,
    required this.createdAt,
    this.checkoutId = '',
    this.deliveryFee = 3000,
    this.discount = 0,
    this.commission,
    this.sellerNet,
    this.deliveryMode = DeliveryMode.home,
    this.deliverySlot,
    this.acceptBefore,
    this.events = const [],
    this.address,
    this.paymentMethod = PaymentMethod.mvola,
    this.courier,
    this.eta,
  });

  factory Order.fromJson(JsonMap json) => Order(
        id: readString(json['id']),
        number: readString(json['number']),
        checkoutId: readString(json['checkoutId']),
        shop: OrderParty.fromJson(readMap(json['shop'])),
        buyer: OrderParty.fromJson(readMap(json['buyer'])),
        status: OrderStatus.fromApi(json['status']),
        items: readList(json['items'], OrderItem.fromJson),
        deliveryFee: readInt(json['deliveryFee']),
        discount: readInt(json['discount']),
        commission: readIntOrNull(json['commission']),
        sellerNet: readIntOrNull(json['sellerNet']),
        deliveryMode: DeliveryMode.fromApi(json['deliveryMode']),
        deliverySlot: readStringOrNull(json['deliverySlot']),
        acceptBefore: readDate(json['acceptBefore']),
        createdAt: readDate(json['createdAt']) ?? DateTime.now(),
        events: readList(json['events'], OrderEvent.fromJson),
        address: readStringOrNull(json['address']),
        paymentMethod: PaymentMethod.fromApi(json['paymentMethod']),
        courier: json['courier'] is Map ? Courier.fromJson(readMap(json['courier'])) : null,
        eta: readStringOrNull(json['eta']),
      );

  final String id;

  /// `IMB-24821`
  final String number;
  final String checkoutId;
  final OrderParty shop;
  final OrderParty buyer;
  final OrderStatus status;
  final List<OrderItem> items;
  final int deliveryFee;
  final int discount;
  final int? commission;
  final int? sellerNet;
  final DeliveryMode deliveryMode;

  /// "demain 8h–12h"
  final String? deliverySlot;
  final DateTime? acceptBefore;
  final DateTime createdAt;
  final List<OrderEvent> events;
  final String? address;
  final PaymentMethod paymentMethod;
  final Courier? courier;

  /// "Arrivée 10h – 11h"
  final String? eta;

  int get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get total => subtotal + deliveryFee - discount;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// "Brèdes mafana ×3 · Tomates 2 kg"
  String get itemsSummary => items
      .map((i) => i.quantityLabel != null ? '${i.productName} ${i.quantityLabel}' : '${i.productName} ×${i.quantity}')
      .join(' · ');

  DateTime? eventDate(OrderStatus s) {
    for (final e in events) {
      if (e.status == s) return e.createdAt;
    }
    return null;
  }

  Order copyWith({OrderStatus? status, List<OrderEvent>? events}) => Order(
        id: id,
        number: number,
        checkoutId: checkoutId,
        shop: shop,
        buyer: buyer,
        status: status ?? this.status,
        items: items,
        deliveryFee: deliveryFee,
        discount: discount,
        commission: commission,
        sellerNet: sellerNet,
        deliveryMode: deliveryMode,
        deliverySlot: deliverySlot,
        acceptBefore: acceptBefore,
        createdAt: createdAt,
        events: events ?? this.events,
        address: address,
        paymentMethod: paymentMethod,
        courier: courier,
        eta: eta,
      );

  JsonMap toJson() => compactJson({
        'id': id,
        'number': number,
        'checkoutId': checkoutId,
        'shop': shop.toJson(),
        'buyer': buyer.toJson(),
        'status': status.apiName,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'commission': commission,
        'total': total,
        'sellerNet': sellerNet,
        'deliveryMode': deliveryMode.apiName,
        'deliverySlot': deliverySlot,
        'acceptBefore': acceptBefore?.toUtc().toIso8601String(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'events': events.map((e) => e.toJson()).toList(),
        'address': address,
        'paymentMethod': paymentMethod.apiName,
        'courier': courier?.toJson(),
        'eta': eta,
      });
}

/// A buyer's purchase = one checkout, i.e. the orders of several shops paid
/// together ("Mes commandes").
class Purchase {
  const Purchase({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.orders,
    this.discount = 0,
    this.promoCode,
    this.paymentMethod = PaymentMethod.mvola,
    this.note,
    this.reviewed = false,
  });

  /// Groups `/me/orders` by `checkoutId`.
  static List<Purchase> groupOrders(List<Order> orders) {
    final map = <String, List<Order>>{};
    for (final o in orders) {
      map.putIfAbsent(o.checkoutId.isEmpty ? o.id : o.checkoutId, () => []).add(o);
    }
    final purchases = [
      for (final entry in map.entries)
        Purchase(
          id: entry.value.first.id,
          number: entry.value.first.number,
          createdAt: entry.value.first.createdAt,
          orders: entry.value,
          discount: entry.value.fold(0, (sum, o) => sum + o.discount),
          paymentMethod: entry.value.first.paymentMethod,
        ),
    ];
    purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return purchases;
  }

  final String id;
  final String number;
  final DateTime createdAt;
  final List<Order> orders;
  final int discount;
  final String? promoCode;
  final PaymentMethod paymentMethod;

  /// Info line ("Arrivée prévue aujourd’hui, 10h–11h").
  final String? note;

  /// All products of the purchase already reviewed.
  final bool reviewed;

  int get subtotal => orders.fold(0, (sum, o) => sum + o.subtotal);
  int get deliveryFee => orders.fold(0, (sum, o) => sum + o.deliveryFee);
  int get total => subtotal + deliveryFee - discount;
  int get itemCount => orders.fold(0, (sum, o) => sum + o.itemCount);
  List<OrderItem> get items => [for (final o in orders) ...o.items];

  /// Aggregated status shown on the list.
  OrderStatus get status {
    const priority = [
      OrderStatus.inDelivery,
      OrderStatus.prepared,
      OrderStatus.accepted,
      OrderStatus.pendingConfirmation,
      OrderStatus.delivered,
      OrderStatus.refused,
      OrderStatus.cancelled,
    ];
    for (final s in priority) {
      if (orders.any((o) => o.status == s)) return s;
    }
    return OrderStatus.pendingConfirmation;
  }

  bool get isActive => orders.any((o) => o.status.isActive);
  bool get canReview => orders.any((o) => o.status == OrderStatus.delivered);
}
