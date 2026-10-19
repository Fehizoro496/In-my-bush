package mg.inmybush.api.admin.dto;

import java.util.UUID;
import mg.inmybush.api.catalog.entity.Category;

/** A category as the backoffice manages it, active or not, with all its products whatever their status. */
public record AdminCategoryResponse(UUID id, UUID parentId, String parentName, String name, String slug, String icon,
                                    int position, boolean active, long productCount) {

    public static AdminCategoryResponse from(Category c, long productCount) {
        Category parent = c.getParent();
        return new AdminCategoryResponse(c.getId(), parent == null ? null : parent.getId(),
            parent == null ? null : parent.getName(), c.getName(), c.getSlug(), c.getIcon(), c.getPosition(),
            c.isActive(), productCount);
    }
}
