package mg.inmybush.api.cart.dto;

import java.util.UUID;

public record CartItemResponse(
    UUID id,
    UUID productId,
    String productName,
    String productSlug,
    long unitPrice,
    String imageUrl,
    int quantity,
    long lineTotal,
    boolean available) {
}
