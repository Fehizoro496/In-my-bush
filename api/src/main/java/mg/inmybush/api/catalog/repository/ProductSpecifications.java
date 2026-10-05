package mg.inmybush.api.catalog.repository;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;
import java.text.Normalizer;
import java.util.Collection;
import java.util.Locale;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.Product;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.shop.entity.ShopStatus;
import org.springframework.data.jpa.domain.Specification;

/** Composable catalogue filters. Text filters are accent- and case-insensitive (PostgreSQL unaccent). */
public final class ProductSpecifications {

    private ProductSpecifications() {
    }

    public static Specification<Product> publiclyVisible() {
        return (root, query, cb) -> cb.and(
            cb.equal(root.get("status"), ProductStatus.PUBLISHED),
            cb.equal(root.get("shop").get("status"), ShopStatus.ACTIVE));
    }

    public static Specification<Product> matchesText(String q) {
        if (isBlank(q)) return null;
        String pattern = likePattern(q);
        return (root, query, cb) -> cb.or(
            cb.like(normalized(cb, root.get("name")), pattern, '\\'),
            cb.like(normalized(cb, root.get("description")), pattern, '\\'),
            cb.like(normalized(cb, root.get("shop").get("name")), pattern, '\\'));
    }

    public static Specification<Product> inCategories(Collection<UUID> categoryIds) {
        if (categoryIds == null || categoryIds.isEmpty()) return null;
        return (root, query, cb) -> root.get("category").get("id").in(categoryIds);
    }

    public static Specification<Product> inRegion(String region) {
        if (isBlank(region)) return null;
        String pattern = likePattern(region);
        return (root, query, cb) -> cb.or(
            cb.like(normalized(cb, root.get("originRegion")), pattern, '\\'),
            cb.like(normalized(cb, root.get("shop").get("region")), pattern, '\\'),
            cb.like(normalized(cb, root.get("shop").get("city")), pattern, '\\'));
    }

    public static Specification<Product> priceBetween(Long min, Long max) {
        if (min == null && max == null) return null;
        return (root, query, cb) -> {
            if (min != null && max != null) return cb.between(root.get("price"), min, max);
            if (min != null) return cb.greaterThanOrEqualTo(root.get("price"), min);
            return cb.lessThanOrEqualTo(root.get("price"), max);
        };
    }

    public static Specification<Product> inStock(Boolean inStock) {
        if (!Boolean.TRUE.equals(inStock)) return null;
        return (root, query, cb) -> cb.greaterThan(root.get("stock"), 0);
    }

    public static Specification<Product> ofShopSlug(String shopSlug) {
        if (isBlank(shopSlug)) return null;
        return (root, query, cb) -> cb.equal(root.get("shop").get("slug"), shopSlug);
    }

    public static Specification<Product> ofShop(UUID shopId) {
        return (root, query, cb) -> cb.equal(root.get("shop").get("id"), shopId);
    }

    public static Specification<Product> hasStatus(ProductStatus status) {
        if (status == null) return null;
        return (root, query, cb) -> cb.equal(root.get("status"), status);
    }

    public static Specification<Product> notArchived() {
        return (root, query, cb) -> cb.notEqual(root.get("status"), ProductStatus.ARCHIVED);
    }

    private static Expression<String> normalized(CriteriaBuilder cb, Expression<String> expression) {
        return cb.lower(cb.function("unaccent", String.class, expression));
    }

    /** Lower-cased, accent-free "%term%" with LIKE wildcards escaped. */
    static String likePattern(String raw) {
        String s = Normalizer.normalize(raw.trim().toLowerCase(Locale.ROOT), Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        s = s.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
        return "%" + s + "%";
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
