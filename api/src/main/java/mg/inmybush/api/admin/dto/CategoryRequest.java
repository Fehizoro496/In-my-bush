package mg.inmybush.api.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.UUID;

/**
 * Creation or modification of a category. An empty slug is made from the name; no parent makes a
 * top-level category.
 */
public record CategoryRequest(@NotBlank @Size(min = 2, max = 80) String name,
                              @Size(max = 100) String slug,
                              @Size(max = 40) String icon,
                              UUID parentId) {
}
