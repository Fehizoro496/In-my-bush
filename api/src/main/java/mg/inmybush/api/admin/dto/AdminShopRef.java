package mg.inmybush.api.admin.dto;

import java.util.UUID;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.entity.ShopStatus;

/** The shop of an account, as its backoffice sheet links to it. */
public record AdminShopRef(UUID id, String name, String slug, ShopStatus status) {

    public static AdminShopRef from(Shop s) {
        return s == null ? null : new AdminShopRef(s.getId(), s.getName(), s.getSlug(), s.getStatus());
    }
}
