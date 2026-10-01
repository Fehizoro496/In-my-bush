package mg.inmybush.api.order.dto;

import java.time.Instant;
import mg.inmybush.api.order.OrderEvent;
import mg.inmybush.api.order.OrderStatus;

public record OrderEventResponse(OrderStatus status, String note, Instant createdAt) {

    public static OrderEventResponse from(OrderEvent e) {
        return new OrderEventResponse(e.getStatus(), e.getNote(), e.getCreatedAt());
    }
}
