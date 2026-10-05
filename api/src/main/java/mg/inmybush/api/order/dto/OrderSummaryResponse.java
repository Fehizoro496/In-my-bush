package mg.inmybush.api.order.dto;

import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.order.entity.DeliveryMode;
import mg.inmybush.api.order.entity.Order;
import mg.inmybush.api.order.entity.OrderStatus;
import mg.inmybush.api.payment.entity.PaymentStatus;

public record OrderSummaryResponse(
    UUID id,
    String number,
    OrderStatus status,
    PaymentStatus paymentStatus,
    DeliveryMode deliveryMode,
    long total,
    int itemCount,
    String buyerName,
    String shopName,
    String shopSlug,
    Instant createdAt) {

    public static OrderSummaryResponse from(Order o) {
        return new OrderSummaryResponse(o.getId(), o.getNumber(), o.getStatus(), o.getPaymentStatus(),
            o.getDeliveryMode(), o.getTotal(), o.getItems().size(),
            o.getBuyer().getDisplayName(), o.getShop().getName(), o.getShop().getSlug(),
            o.getCreatedAt());
    }
}
