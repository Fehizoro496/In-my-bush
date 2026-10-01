package mg.inmybush.api.catalog.dto;

import java.math.BigDecimal;
import java.util.UUID;
import mg.inmybush.api.shop.Shop;

/** Compact shop info embedded in product cards, carts and orders. */
public record ShopRef(UUID id, String slug, String name, String city, String region, String logoUrl, BigDecimal ratingAvg,
                      int ratingCount) {

    public static ShopRef from(Shop s) {
        return s == null ? null : new ShopRef(s.getId(), s.getSlug(), s.getName(), s.getCity(), s.getRegion(), s.getLogoUrl(),
            s.getRatingAvg(), s.getRatingCount());
    }
}
