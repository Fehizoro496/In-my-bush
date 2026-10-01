package mg.inmybush.api.catalog.dto;

import java.math.BigDecimal;
import java.util.UUID;
import mg.inmybush.api.catalog.ProductUnit;
import mg.inmybush.api.catalog.StockStatus;

/** Product card. {@code discountPercent} is derived from compareAtPrice (promo badge). */
public record ProductSummaryResponse(
    UUID id,
    String slug,
    String name,
    long price,
    Long compareAtPrice,
    Integer discountPercent,
    ProductUnit unit,
    String unitLabel,
    int stock,
    StockStatus stockStatus,
    String imageUrl,
    String originRegion,
    BigDecimal ratingAvg,
    int ratingCount,
    ShopRef shop,
    CategoryRef category) {
}
