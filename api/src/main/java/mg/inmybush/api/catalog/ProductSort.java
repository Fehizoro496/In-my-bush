package mg.inmybush.api.catalog;

import java.util.Locale;
import mg.inmybush.api.common.BadRequestException;
import org.springframework.data.domain.Sort;

/** Values of the {@code sort} query parameter. */
public enum ProductSort {
    NEWEST(Sort.by(Sort.Order.desc("createdAt"))),
    PRICE_ASC(Sort.by(Sort.Order.asc("price"))),
    PRICE_DESC(Sort.by(Sort.Order.desc("price"))),
    RATING(Sort.by(Sort.Order.desc("ratingAvg"), Sort.Order.desc("ratingCount"))),
    POPULAR(Sort.by(Sort.Order.desc("ratingCount"), Sort.Order.desc("ratingAvg")));

    private final Sort sort;

    ProductSort(Sort sort) {
        this.sort = sort;
    }

    public Sort toSort() {
        return sort.and(Sort.by(Sort.Order.asc("id")));
    }

    public static ProductSort parse(String value) {
        if (value == null || value.isBlank() || value.equalsIgnoreCase("relevance")) {
            return NEWEST;
        }
        try {
            return valueOf(value.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            throw new BadRequestException("INVALID_SORT",
                "Tri inconnu : " + value + " (newest, price_asc, price_desc, rating, popular).");
        }
    }
}
