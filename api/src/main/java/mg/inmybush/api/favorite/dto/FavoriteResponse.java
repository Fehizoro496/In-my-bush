package mg.inmybush.api.favorite.dto;

import java.time.Instant;
import java.util.UUID;

public record FavoriteResponse(
    UUID productId,
    String productName,
    String productSlug,
    long price,
    String imageUrl,
    String shopName,
    String shopSlug,
    Instant addedAt) {
}
