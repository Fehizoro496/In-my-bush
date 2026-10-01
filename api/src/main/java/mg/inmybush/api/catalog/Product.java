package mg.inmybush.api.catalog;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import mg.inmybush.api.common.BaseEntity;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.shop.Shop;

@Entity
@Table(name = "products")
public class Product extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(name = "name", nullable = false, length = 160)
    private String name;

    @Column(name = "slug", nullable = false, unique = true, length = 200)
    private String slug;

    @Column(name = "description", columnDefinition = "text")
    private String description;

    @Column(name = "price", nullable = false)
    private long price;

    @Column(name = "compare_at_price")
    private Long compareAtPrice;

    @Enumerated(EnumType.STRING)
    @Column(name = "unit", nullable = false, length = 10)
    private ProductUnit unit;

    @Column(name = "unit_label", length = 40)
    private String unitLabel;

    @Column(name = "stock", nullable = false)
    private int stock;

    @Column(name = "low_stock_threshold", nullable = false)
    private int lowStockThreshold = 5;

    @Column(name = "origin_region", length = 120)
    private String originRegion;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ProductStatus status = ProductStatus.DRAFT;

    @Column(name = "rejection_reason", length = 500)
    private String rejectionReason;

    @Column(name = "rating_avg", nullable = false, precision = 3, scale = 2)
    private BigDecimal ratingAvg = BigDecimal.ZERO;

    @Column(name = "rating_count", nullable = false)
    private int ratingCount;

    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position ASC")
    private List<ProductImage> images = new ArrayList<>();

    protected Product() {
    }

    public Product(Shop shop, Category category, String name, String slug) {
        this.shop = shop;
        this.category = category;
        this.name = name;
        this.slug = slug;
    }

    // ------------------------------------------------------------------ lifecycle

    public void submitForReview() {
        if (status == ProductStatus.PENDING_REVIEW || status == ProductStatus.PUBLISHED) {
            throw new ConflictException("INVALID_PRODUCT_STATUS", "Ce produit est déjà en ligne ou en cours de validation.");
        }
        status = ProductStatus.PENDING_REVIEW;
        rejectionReason = null;
    }

    public void approve() {
        requireStatus(ProductStatus.PENDING_REVIEW);
        status = ProductStatus.PUBLISHED;
        rejectionReason = null;
    }

    public void reject(String reason) {
        requireStatus(ProductStatus.PENDING_REVIEW);
        status = ProductStatus.REJECTED;
        rejectionReason = reason;
    }

    public void archive() {
        status = ProductStatus.ARCHIVED;
    }

    /** A content change on a published product sends it back to moderation. */
    public void markContentChanged() {
        if (status == ProductStatus.PUBLISHED || status == ProductStatus.REJECTED) {
            status = ProductStatus.PENDING_REVIEW;
            rejectionReason = null;
        }
    }

    private void requireStatus(ProductStatus expected) {
        if (status != expected) {
            throw new ConflictException("INVALID_PRODUCT_STATUS",
                "Action impossible : le produit est au statut " + status + ".");
        }
    }

    // ------------------------------------------------------------------ stock

    public boolean isPurchasable() {
        return status == ProductStatus.PUBLISHED && shop.isActive() && stock > 0;
    }

    public void decrementStock(int quantity) {
        if (quantity > stock) {
            throw new ConflictException("INSUFFICIENT_STOCK", "Stock insuffisant pour « " + name + " » (reste " + stock + ").");
        }
        stock -= quantity;
    }

    public void incrementStock(int quantity) {
        stock += quantity;
    }

    public StockStatus getStockStatus() {
        if (stock <= 0) return StockStatus.OUT_OF_STOCK;
        if (stock <= lowStockThreshold) return StockStatus.LOW_STOCK;
        return StockStatus.IN_STOCK;
    }

    // ------------------------------------------------------------------ images

    public void replaceImages(List<String> urls) {
        images.clear();
        if (urls == null) return;
        for (int i = 0; i < urls.size(); i++) {
            images.add(new ProductImage(this, urls.get(i), i));
        }
    }

    public List<String> getImageUrls() {
        return images.stream().map(ProductImage::getUrl).toList();
    }

    public String getMainImageUrl() {
        return images.isEmpty() ? null : images.get(0).getUrl();
    }

    // ------------------------------------------------------------------ accessors

    public Shop getShop() { return shop; }

    public Category getCategory() { return category; }

    public void setCategory(Category category) { this.category = category; }

    public String getName() { return name; }

    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }

    public String getDescription() { return description; }

    public void setDescription(String description) { this.description = description; }

    public long getPrice() { return price; }

    public void setPrice(long price) { this.price = price; }

    public Long getCompareAtPrice() { return compareAtPrice; }

    public void setCompareAtPrice(Long compareAtPrice) { this.compareAtPrice = compareAtPrice; }

    public ProductUnit getUnit() { return unit; }

    public void setUnit(ProductUnit unit) { this.unit = unit; }

    public String getUnitLabel() { return unitLabel; }

    public void setUnitLabel(String unitLabel) { this.unitLabel = unitLabel; }

    public int getStock() { return stock; }

    public void setStock(int stock) { this.stock = stock; }

    public int getLowStockThreshold() { return lowStockThreshold; }

    public void setLowStockThreshold(int lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public String getOriginRegion() { return originRegion; }

    public void setOriginRegion(String originRegion) { this.originRegion = originRegion; }

    public ProductStatus getStatus() { return status; }

    public String getRejectionReason() { return rejectionReason; }

    public BigDecimal getRatingAvg() { return ratingAvg; }

    public int getRatingCount() { return ratingCount; }

    public void updateRating(BigDecimal avg, int count) {
        this.ratingAvg = avg;
        this.ratingCount = count;
    }
}
