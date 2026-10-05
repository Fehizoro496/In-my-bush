
import '../../../../shared/models/avatar_look.dart';

/// One shop's part of the confirmed checkout (confirmation screen).
class CheckoutDelivery {
  const CheckoutDelivery({required this.shopName, required this.avatar, required this.itemsSummary, required this.when});

  final String shopName;
  final AvatarLook avatar;
  final String itemsSummary;
  final String when;
}
