package mg.inmybush.api.order.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.order.DeliveryMode;
import mg.inmybush.api.order.Order;
import mg.inmybush.api.order.OrderStatus;
import mg.inmybush.api.payment.PaymentStatus;

public record OrderResponse(
    UUID id,
    String number,
    OrderStatus status,
    PaymentStatus paymentStatus,
    DeliveryMode deliveryMode,
    long subtotal,
    long deliveryFee,
    long discount,
    long total,
    String deliverySlot,
    Instant acceptBefore,
    Instant deliveredAt,
    Instant deliveryConfirmedAt,
    String cancelReason,
    String buyerName,
    String shopName,
    String shopSlug,
    List<OrderItemResponse> items,
    List<OrderEventResponse> events,
    Instant createdAt) {

    public static OrderResponse from(Order o) {
        return new OrderResponse(o.getId(), o.getNumber(), o.getStatus(), o.getPaymentStatus(),
            o.getDeliveryMode(), o.getSubtotal(), o.getDeliveryFee(), o.getDiscount(), o.getTotal(),
            o.getDeliverySlot(), o.getAcceptBefore(), o.getDeliveredAt(), o.getDeliveryConfirmedAt(),
            o.getCancelReason(), o.getBuyer().getDisplayName(), o.getShop().getName(), o.getShop().getSlug(),
            o.getItems().stream().map(OrderItemResponse::from).toList(),
            o.getEvents().stream().map(OrderEventResponse::from).toList(),
            o.getCreatedAt());
    }
}
