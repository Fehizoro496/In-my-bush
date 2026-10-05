package mg.inmybush.api.catalog.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.ProductUnit;
import mg.inmybush.api.catalog.entity.StockStatus;

public record ProductDetailResponse(
    UUID id,
    String slug,
    String name,
    String description,
    long price,
    Long compareAtPrice,
    Integer discountPercent,
    ProductUnit unit,
    String unitLabel,
    int stock,
    StockStatus stockStatus,
    List<String> images,
    String originRegion,
    BigDecimal ratingAvg,
    int ratingCount,
    ShopRef shop,
    CategoryRef category,
    Instant createdAt) {
}
