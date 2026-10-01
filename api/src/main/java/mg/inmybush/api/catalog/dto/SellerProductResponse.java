package mg.inmybush.api.catalog.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.catalog.ProductStatus;
import mg.inmybush.api.catalog.ProductUnit;
import mg.inmybush.api.catalog.StockStatus;

/** Seller / admin view of a product, including moderation status. */
public record SellerProductResponse(
    UUID id,
    String slug,
    String name,
    String description,
    long price,
    Long compareAtPrice,
    ProductUnit unit,
    String unitLabel,
    int stock,
    int lowStockThreshold,
    StockStatus stockStatus,
    String originRegion,
    ProductStatus status,
    String rejectionReason,
    List<String> images,
    CategoryRef category,
    ShopRef shop,
    BigDecimal ratingAvg,
    int ratingCount,
    Instant createdAt,
    Instant updatedAt) {
}
