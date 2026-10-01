import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/data/catalog_models.dart';
import '../orders/data/order_models.dart';
import 'data/seller_models.dart';
import 'data/seller_repository.dart';

final sellerDashboardProvider = FutureProvider.autoDispose.family<SellerDashboard, SalesPeriod>(
  (ref, period) => ref.watch(sellerRepositoryProvider).getDashboard(period),
);

/// Seller products with inline stock / visibility edits (Mes produits).
class SellerProductsController extends AsyncNotifier<List<Product>> {
  SellerRepository get _repo => ref.read(sellerRepositoryProvider);

  @override
  Future<List<Product>> build() => ref.watch(sellerRepositoryProvider).getProducts();

  void _replace(Product product) {
    final list = state.valueOrNull ?? const <Product>[];
    state = AsyncData([for (final p in list) p.id == product.id ? product : p]);
  }

  Future<void> setStock(Product product, int stock) async {
    _replace(product.copyWith(stock: stock < 0 ? 0 : stock));
    _replace(await _repo.updateStock(product.id, stock < 0 ? 0 : stock));
  }

  Future<void> setVisible(Product product, bool visible) async {
    _replace(product.copyWith(visible: visible));
    _replace(await _repo.setVisibility(product.id, visible));
  }

  Future<Product> save(ProductDraft draft) async {
    final saved = await _repo.saveProduct(draft);
    ref.invalidateSelf();
    return saved;
  }

  Future<void> delete(String id) async {
    await _repo.deleteProduct(id);
    final list = state.valueOrNull ?? const <Product>[];
    state = AsyncData(list.where((p) => p.id != id).toList());
  }
}

final sellerProductsProvider =
    AsyncNotifierProvider<SellerProductsController, List<Product>>(SellerProductsController.new);

final sellerProductProvider = FutureProvider.autoDispose.family<Product, String>(
  (ref, id) => ref.watch(sellerRepositoryProvider).getProduct(id),
);

final sellerOrdersProvider = FutureProvider.autoDispose<List<Order>>(
  (ref) => ref.watch(sellerRepositoryProvider).getOrders(),
);

/// One received order with its status machine (Accepter → Préparée →
/// Remise au livreur → Livrée).
class SellerOrderController extends AutoDisposeFamilyAsyncNotifier<Order, String> {
  @override
  Future<Order> build(String arg) => ref.watch(sellerRepositoryProvider).getOrder(arg);

  Future<void> advance() async {
    final order = state.valueOrNull;
    if (order == null) return;
    const actions = {
      OrderStatus.pendingConfirmation: 'accept',
      OrderStatus.accepted: 'prepare',
      OrderStatus.prepared: 'ship',
      OrderStatus.inDelivery: 'deliver',
    };
    final action = actions[order.status];
    if (action == null) return;
    state = AsyncData(await ref.read(sellerRepositoryProvider).transition(order.id, action));
    ref.invalidate(sellerOrdersProvider);
  }

  Future<void> refuse() async {
    final order = state.valueOrNull;
    if (order == null) return;
    state = AsyncData(await ref.read(sellerRepositoryProvider).transition(order.id, 'refuse'));
    ref.invalidate(sellerOrdersProvider);
  }
}

final sellerOrderProvider =
    AsyncNotifierProvider.autoDispose.family<SellerOrderController, Order, String>(SellerOrderController.new);

final salesHistoryProvider = FutureProvider.autoDispose.family<SalesHistory, SalesPeriod>(
  (ref, period) => ref.watch(sellerRepositoryProvider).getSales(period),
);

class SellerReviewsController extends AsyncNotifier<List<Review>> {
  @override
  Future<List<Review>> build() => ref.watch(sellerRepositoryProvider).getReviews();

  Future<void> reply(Review review, String text) async {
    final updated = await ref.read(sellerRepositoryProvider).reply(review.id, text);
    final list = state.valueOrNull ?? const <Review>[];
    state = AsyncData([for (final r in list) r.id == review.id ? updated : r]);
  }
}

final sellerReviewsProvider =
    AsyncNotifierProvider<SellerReviewsController, List<Review>>(SellerReviewsController.new);

final shopSettingsProvider = FutureProvider.autoDispose<ShopSettings>(
  (ref) => ref.watch(sellerRepositoryProvider).getShopSettings(),
);
