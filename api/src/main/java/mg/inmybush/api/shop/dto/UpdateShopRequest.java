package mg.inmybush.api.shop.dto;

import jakarta.validation.constraints.Size;
import mg.inmybush.api.shop.entity.ShopStatus;

/** PATCH semantics. {@code status} accepts ACTIVE or PAUSED (holiday mode); SUSPENDED is admin-only. */
public record UpdateShopRequest(
    @Size(min = 2, max = 120) String name,
    @Size(max = 2000) String description,
    @Size(max = 120) String region,
    @Size(max = 120) String city,
    @Size(max = 500) String logoUrl,
    @Size(max = 500) String coverUrl,
    ShopStatus status) {
}
