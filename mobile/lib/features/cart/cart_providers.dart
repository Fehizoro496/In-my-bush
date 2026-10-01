import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/data/catalog_models.dart';
import 'data/cart_models.dart';
import 'data/cart_repository.dart';

/// Cart state shared by the top-bar badge, product cards, cart and checkout.
class CartController extends AsyncNotifier<Cart> {
  CartRepository get _repo => ref.read(cartRepositoryProvider);

  @override
  Future<Cart> build() => ref.watch(cartRepositoryProvider).getCart();

  Cart get _current => state.valueOrNull ?? Cart.empty;

  Future<void> add(Product product, {int quantity = 1}) async {
    state = AsyncData(await _repo.addItem(product, quantity));
  }

  Future<void> setQuantity(CartItem item, int quantity) async {
    if (quantity < 1) return remove(item);
    // Optimistic update so the stepper feels instant.
    state = AsyncData(_current.copyWith(
      items: [for (final i in _current.items) i.id == item.id ? i.copyWith(quantity: quantity) : i],
    ));
    final promo = _current.promoCode;
    final updated = await _repo.updateQuantity(item.id, quantity);
    state = AsyncData(updated.copyWith(promoCode: promo));
  }

  Future<void> remove(CartItem item) async {
    final promo = _current.promoCode;
    state = AsyncData(_current.copyWith(items: _current.items.where((i) => i.id != item.id).toList()));
    final updated = await _repo.removeItem(item.id);
    state = AsyncData(updated.copyWith(promoCode: promo));
  }

  Future<void> clear() async {
    state = AsyncData(await _repo.clear());
  }

  /// Returns `false` when the code is unknown.
  bool applyPromo(String code) {
    final normalized = code.trim().toUpperCase();
    if (!Cart.promoRates.containsKey(normalized)) return false;
    state = AsyncData(_current.copyWith(promoCode: normalized));
    return true;
  }

  void removePromo() => state = AsyncData(_current.copyWith(clearPromo: true));
}

final cartControllerProvider = AsyncNotifierProvider<CartController, Cart>(CartController.new);

/// Badge on the cart icon (number of lines).
final cartCountProvider = Provider<int>((ref) => ref.watch(cartControllerProvider).valueOrNull?.lineCount ?? 0);

/// Whether a product is already in the cart (✓ on product cards).
final isInCartProvider = Provider.family<bool, String>(
  (ref, productId) => (ref.watch(cartControllerProvider).valueOrNull?.quantityOf(productId) ?? 0) > 0,
);
