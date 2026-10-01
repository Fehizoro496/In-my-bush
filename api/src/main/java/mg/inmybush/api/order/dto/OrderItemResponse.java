package mg.inmybush.api.order.dto;

import java.util.UUID;
import mg.inmybush.api.order.OrderItem;

public record OrderItemResponse(
    UUID id,
    UUID productId,
    String productName,
    String productSlug,
    String imageUrl,
    long unitPrice,
    String unitLabel,
    int quantity,
    long lineTotal) {

    public static OrderItemResponse from(OrderItem item) {
        return new OrderItemResponse(item.getId(), item.getProductId(), item.getProductName(),
            item.getProductSlug(), item.getImageUrl(), item.getUnitPrice(), item.getUnitLabel(),
            item.getQuantity(), item.getLineTotal());
    }
}
