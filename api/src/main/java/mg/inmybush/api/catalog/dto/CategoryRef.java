package mg.inmybush.api.catalog.dto;

import java.util.UUID;
import mg.inmybush.api.catalog.Category;

public record CategoryRef(UUID id, String slug, String name) {

    public static CategoryRef from(Category c) {
        return c == null ? null : new CategoryRef(c.getId(), c.getSlug(), c.getName());
    }
}
