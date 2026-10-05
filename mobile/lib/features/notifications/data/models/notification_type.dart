

/// `notifications.type` → icon and colors of the list row.
enum NotificationType {
  order('ORDER', 'truck', '#E8F1FA', '#2F6DA8'),
  sale('SALE', 'store', '#F0F6E6', '#4A7A12'),
  promo('PROMO', 'percent', '#FFF4E8', '#D86F12'),
  message('MESSAGE', 'msg', '#F4F0E6', '#4A4A42'),
  stock('STOCK', 'alert', '#FFF1E0', '#B4500A'),
  review('REVIEW', 'starO', '#FFF4E8', '#D86F12'),
  payout('PAYOUT', 'wallet', '#F0F6E6', '#4A7A12');

  const NotificationType(this.apiName, this.icon, this.background, this.foreground);

  final String apiName;
  final String icon;
  final String background;
  final String foreground;

  /// The API types are finer grained (`ORDER_PLACED`, `PRODUCT_APPROVED`,
  /// `NEW_REVIEW`, `NEW_MESSAGE`, `PAYOUT_SENT`…).
  static NotificationType fromApi(Object? v) {
    final name = v?.toString() ?? '';
    for (final type in NotificationType.values) {
      if (type.apiName == name) return type;
    }
    if (name == 'NEW_MESSAGE') return NotificationType.message;
    if (name == 'NEW_REVIEW') return NotificationType.review;
    if (name == 'PAYOUT_SENT') return NotificationType.payout;
    if (name.startsWith('PRODUCT_')) return NotificationType.sale;
    return NotificationType.order;
  }
}
