package mg.inmybush.api.admin.dto;

import java.util.UUID;

/** Category that receives the products of the deactivated one; required when it still has products. */
public record DeactivateCategoryRequest(UUID replacementId) {
}
