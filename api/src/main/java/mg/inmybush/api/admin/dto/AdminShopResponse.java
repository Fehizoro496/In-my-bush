package mg.inmybush.api.admin.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.entity.ShopStatus;
import mg.inmybush.api.user.entity.User;
import mg.inmybush.api.user.entity.UserStatus;

/** A shop as the backoffice manages it, with its owner and its products counted by status. */
public record AdminShopResponse(
    UUID id,
    String name,
    String slug,
    String description,
    String city,
    String region,
    ShopStatus status,
    UUID ownerId,
    String ownerName,
    String ownerPhone,
    UserStatus ownerStatus,
    Map<ProductStatus, Long> productCounts,
    BigDecimal ratingAvg,
    int ratingCount,
    Instant createdAt) {

    public static AdminShopResponse from(Shop s, Map<ProductStatus, Long> productCounts) {
        User owner = s.getOwner();
        return new AdminShopResponse(s.getId(), s.getName(), s.getSlug(), s.getDescription(), s.getCity(), s.getRegion(),
            s.getStatus(), owner.getId(), owner.getFullName(), owner.getPhone(), owner.getStatus(), productCounts,
            s.getRatingAvg(), s.getRatingCount(), s.getCreatedAt());
    }
}
