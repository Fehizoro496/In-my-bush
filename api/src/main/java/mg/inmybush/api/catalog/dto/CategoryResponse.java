package mg.inmybush.api.catalog.dto;

import java.util.UUID;

public record CategoryResponse(UUID id, UUID parentId, String name, String slug, String icon, int position, long productCount) {
}
