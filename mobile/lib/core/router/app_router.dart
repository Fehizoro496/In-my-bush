import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/addresses_screen.dart';
import '../../features/account/presentation/payments_screen.dart';
import '../../features/account/presentation/profile_screen.dart';
import '../../features/account/presentation/settings_screen.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/catalog/presentation/categories_screen.dart';
import '../../features/catalog/presentation/filters_sheet.dart';
import '../../features/catalog/presentation/home_screen.dart';
import '../../features/catalog/presentation/product_screen.dart';
import '../../features/catalog/presentation/search_screen.dart';
import '../../features/catalog/presentation/seller_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/confirmation_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/messages/messages_providers.dart';
import '../../features/messages/presentation/chat_screen.dart';
import '../../features/messages/presentation/messages_screen.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/reviews/presentation/review_screen.dart';
import '../../features/seller/presentation/become_seller_screen.dart';
import '../../features/seller/presentation/my_products_screen.dart';
import '../../features/seller/presentation/order_received_screen.dart';
import '../../features/seller/presentation/orders_received_screen.dart';
import '../../features/seller/presentation/product_form_screen.dart';
import '../../features/seller/presentation/reviews_received_screen.dart';
import '../../features/seller/presentation/sales_history_screen.dart';
import '../../features/seller/presentation/sell_dashboard_screen.dart';
import '../../features/seller/presentation/shop_profile_screen.dart';
import '../../shared/widgets/main_tab_scaffold.dart';
import 'bottom_sheet_page.dart';
import 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Every mobile route of docs/architecture.md §4.
///
/// Tabs (StatefulShellRoute.indexedStack): Accueil `/` · Messages
/// `/messages` · Vendre `/vendre` · Notifs `/notifications` · Paramètres
/// `/parametres`. Screens shown with the tab bar in the mockups live inside
/// their branch; the others are pushed on the root navigator.
///
/// The whole app requires a session: without an authenticated user every
/// route redirects to `/connexion`.
final routerProvider = Provider<GoRouter>((ref) {
  // Re-evaluates the redirect whenever the session changes.
  final session = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => session.value++);
  ref.onDispose(session.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    refreshListenable: session,
    redirect: (context, state) {
      final signedIn = ref.read(authControllerProvider).valueOrNull != null;
      final onLogin = state.matchedLocation == AppRoutes.login;
      if (!signedIn) return onLogin ? null : AppRoutes.login;
      return onLogin ? AppRoutes.home : null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _TabShell(navigationShell: navigationShell),
        branches: [
          // 0 · Accueil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'categories',
                    name: RouteNames.categories,
                    builder: (context, state) => const CategoriesScreen(),
                  ),
                ],
              ),
            ],
          ),
          // 1 · Messages
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                name: RouteNames.messages,
                builder: (context, state) => const MessagesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.chat,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ChatScreen(conversationId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          // 2 · Vendre
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sell,
                name: RouteNames.sell,
                builder: (context, state) => const SellDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'ouvrir-ma-boutique',
                    name: RouteNames.becomeSeller,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const BecomeSellerScreen(),
                  ),
                  GoRoute(
                    path: 'produits',
                    name: RouteNames.myProducts,
                    builder: (context, state) => const MyProductsScreen(),
                    routes: [
                      GoRoute(
                        path: 'nouveau',
                        name: RouteNames.addProduct,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const AddProductScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: RouteNames.editProduct,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => EditProductScreen(productId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'commandes',
                    name: RouteNames.ordersReceived,
                    builder: (context, state) => const OrdersReceivedScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: RouteNames.orderReceived,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => OrderReceivedScreen(orderId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'historique',
                    name: RouteNames.salesHistory,
                    builder: (context, state) => const SalesHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'avis',
                    name: RouteNames.reviewsReceived,
                    builder: (context, state) => const ReviewsReceivedScreen(),
                  ),
                  GoRoute(
                    path: 'boutique',
                    name: RouteNames.shopProfile,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ShopProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
          // 3 · Notifs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                name: RouteNames.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          // 4 · Paramètres (+ profil, favoris, commandes, shown with the tab bar)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: RouteNames.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: AppRoutes.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: AppRoutes.favorites,
                name: RouteNames.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: AppRoutes.orders,
                name: RouteNames.orders,
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.orderDetail,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'avis',
                        name: RouteNames.review,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => ReviewScreen(orderId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.filters,
        name: RouteNames.filters,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => BottomSheetPage<void>(key: state.pageKey, child: const FiltersSheet()),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: RouteNames.search,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => SearchScreen(initialQuery: state.uri.queryParameters['q']),
      ),
      GoRoute(
        path: '/produits/:slug',
        name: RouteNames.product,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ProductScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/vendeurs/:slug',
        name: RouteNames.seller,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => SellerScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: RouteNames.cart,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: RouteNames.checkout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
        routes: [
          GoRoute(
            path: 'confirmation',
            name: RouteNames.confirmation,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ConfirmationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        name: RouteNames.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        name: RouteNames.addresses,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        name: RouteNames.payments,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PaymentsScreen(),
      ),
    ],
  );
});

/// Shell with live badge counts.
class _TabShell extends ConsumerWidget {
  const _TabShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainTabScaffold(
      navigationShell: navigationShell,
      messagesCount: ref.watch(unreadMessagesCountProvider),
      notificationsCount: ref.watch(unreadNotificationsCountProvider),
    );
  }
}
