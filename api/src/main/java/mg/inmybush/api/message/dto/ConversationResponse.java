package mg.inmybush.api.message.dto;

import java.time.Instant;
import java.util.UUID;

public record ConversationResponse(
    UUID id,
    UUID buyerId,
    UUID shopId,
    String shopName,
    String buyerName,
    UUID productId,
    UUID orderId,
    String lastMessagePreview,
    Instant lastMessageAt,
    Instant createdAt) {
}
