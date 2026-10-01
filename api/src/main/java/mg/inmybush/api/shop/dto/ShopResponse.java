package mg.inmybush.api.shop.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.shop.Shop;
import mg.inmybush.api.shop.ShopStatus;

public record ShopResponse(
    UUID id,
    String slug,
    String name,
    String description,
    String region,
    String city,
    String logoUrl,
    String coverUrl,
    ShopStatus status,
    BigDecimal ratingAvg,
    int ratingCount,
    long productCount,
    String ownerName,
    Instant createdAt) {

    public static ShopResponse from(Shop s, long productCount) {
        return new ShopResponse(s.getId(), s.getSlug(), s.getName(), s.getDescription(), s.getRegion(), s.getCity(),
            s.getLogoUrl(), s.getCoverUrl(), s.getStatus(), s.getRatingAvg(), s.getRatingCount(), productCount,
            s.getOwner().getDisplayName(), s.getCreatedAt());
    }
}
