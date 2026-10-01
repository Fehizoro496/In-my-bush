package mg.inmybush.api.catalog;

import mg.inmybush.api.catalog.dto.CategoryRef;
import mg.inmybush.api.catalog.dto.ProductDetailResponse;
import mg.inmybush.api.catalog.dto.ProductSummaryResponse;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.catalog.dto.ShopRef;

/** Manual entity → DTO mapping for products. */
public final class ProductMapper {

    private ProductMapper() {
    }

    public static ProductSummaryResponse toSummary(Product p) {
        return new ProductSummaryResponse(p.getId(), p.getSlug(), p.getName(), p.getPrice(), p.getCompareAtPrice(),
            discountPercent(p), p.getUnit(), p.getUnitLabel(), p.getStock(), p.getStockStatus(), p.getMainImageUrl(),
            p.getOriginRegion(), p.getRatingAvg(), p.getRatingCount(), ShopRef.from(p.getShop()), CategoryRef.from(p.getCategory()));
    }

    public static ProductDetailResponse toDetail(Product p) {
        return new ProductDetailResponse(p.getId(), p.getSlug(), p.getName(), p.getDescription(), p.getPrice(),
            p.getCompareAtPrice(), discountPercent(p), p.getUnit(), p.getUnitLabel(), p.getStock(), p.getStockStatus(),
            p.getImageUrls(), p.getOriginRegion(), p.getRatingAvg(), p.getRatingCount(), ShopRef.from(p.getShop()),
            CategoryRef.from(p.getCategory()), p.getCreatedAt());
    }

    public static SellerProductResponse toSellerView(Product p) {
        return new SellerProductResponse(p.getId(), p.getSlug(), p.getName(), p.getDescription(), p.getPrice(),
            p.getCompareAtPrice(), p.getUnit(), p.getUnitLabel(), p.getStock(), p.getLowStockThreshold(), p.getStockStatus(),
            p.getOriginRegion(), p.getStatus(), p.getRejectionReason(), p.getImageUrls(), CategoryRef.from(p.getCategory()),
            ShopRef.from(p.getShop()), p.getRatingAvg(), p.getRatingCount(), p.getCreatedAt(), p.getUpdatedAt());
    }

    /** "−20 %" badge: rounded percentage off the compare-at price, null without a promo. */
    public static Integer discountPercent(Product p) {
        Long old = p.getCompareAtPrice();
        if (old == null || old <= p.getPrice()) {
            return null;
        }
        return (int) Math.round((old - p.getPrice()) * 100.0 / old);
    }
}
