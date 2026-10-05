package mg.inmybush.api.order.service;

import java.util.UUID;
import mg.inmybush.api.common.ForbiddenException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.order.dto.OrderResponse;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.order.entity.Order;
import mg.inmybush.api.order.entity.OrderStatus;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.service.ShopService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {

    private final OrderRepository orders;
    private final ShopService shopService;

    public OrderService(OrderRepository orders, ShopService shopService) {
        this.orders = orders;
        this.shopService = shopService;
    }

    // ------------------------------------------------------------------ buyer

    @Transactional(readOnly = true)
    public PageResponse<OrderSummaryResponse> buyerOrders(UUID buyerId, int page, int size) {
        return PageResponse.of(orders.findByBuyerId(buyerId, Pages.newestFirst(page, size)), OrderSummaryResponse::from);
    }

    @Transactional(readOnly = true)
    public OrderResponse buyerOrder(UUID buyerId, UUID orderId) {
        Order order = orders.findByIdAndBuyerId(orderId, buyerId)
            .orElseThrow(() -> NotFoundException.of("Commande", orderId));
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse cancel(UUID buyerId, UUID orderId, String reason) {
        Order order = orders.findByIdAndBuyerId(orderId, buyerId)
            .orElseThrow(() -> NotFoundException.of("Commande", orderId));
        order.cancel(reason);
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse confirmDelivery(UUID buyerId, UUID orderId) {
        Order order = orders.findByIdAndBuyerId(orderId, buyerId)
            .orElseThrow(() -> NotFoundException.of("Commande", orderId));
        order.confirmDelivery();
        return OrderResponse.from(order);
    }

    // ------------------------------------------------------------------ seller

    @Transactional(readOnly = true)
    public PageResponse<OrderSummaryResponse> sellerOrders(UUID userId, OrderStatus status, int page, int size) {
        Shop shop = shopService.requireMyShop(userId);
        if (status != null) {
            return PageResponse.of(orders.findByShopIdAndStatus(shop.getId(), status, Pages.newestFirst(page, size)),
                OrderSummaryResponse::from);
        }
        return PageResponse.of(orders.findByShopId(shop.getId(), Pages.newestFirst(page, size)),
            OrderSummaryResponse::from);
    }

    @Transactional(readOnly = true)
    public OrderResponse sellerOrder(UUID userId, UUID orderId) {
        Shop shop = shopService.requireMyShop(userId);
        Order order = orders.findByIdAndShopId(orderId, shop.getId())
            .orElseThrow(() -> NotFoundException.of("Commande", orderId));
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse accept(UUID userId, UUID orderId) {
        Order order = requireSellerOrder(userId, orderId);
        order.accept();
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse refuse(UUID userId, UUID orderId, String reason) {
        Order order = requireSellerOrder(userId, orderId);
        order.refuse(reason);
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse prepare(UUID userId, UUID orderId) {
        Order order = requireSellerOrder(userId, orderId);
        order.prepare();
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse ship(UUID userId, UUID orderId) {
        Order order = requireSellerOrder(userId, orderId);
        order.ship();
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse deliver(UUID userId, UUID orderId) {
        Order order = requireSellerOrder(userId, orderId);
        order.deliver();
        return OrderResponse.from(order);
    }

    private Order requireSellerOrder(UUID userId, UUID orderId) {
        Shop shop = shopService.requireMyShop(userId);
        return orders.findByIdAndShopId(orderId, shop.getId())
            .orElseThrow(() -> NotFoundException.of("Commande", orderId));
    }
}
