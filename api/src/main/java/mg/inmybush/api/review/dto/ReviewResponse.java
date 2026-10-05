package mg.inmybush.api.review.dto;

import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.review.entity.Review;

public record ReviewResponse(
    UUID id,
    UUID productId,
    String productName,
    String productSlug,
    UUID orderId,
    String authorName,
    int rating,
    String comment,
    String sellerReply,
    Instant repliedAt,
    Instant createdAt) {

    public static ReviewResponse from(Review r) {
        return new ReviewResponse(r.getId(), r.getProduct().getId(), r.getProduct().getName(),
            r.getProduct().getSlug(), r.getOrder().getId(), r.getAuthor().getDisplayName(),
            r.getRating(), r.getComment(), r.getSellerReply(), r.getRepliedAt(), r.getCreatedAt());
    }
}
