package mg.inmybush.api.catalog.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.ProductUnit;

/**
 * PATCH semantics. Editing name, description, category or images of a published product sends it back to moderation;
 * price, unit and stock changes apply immediately. {@code compareAtPrice = 0} removes the promo price.
 */
public record SellerProductUpdateRequest(
    @Size(min = 1, max = 160) String name,
    UUID categoryId,
    @Size(max = 5000) String description,
    @Positive Long price,
    @Min(0) Long compareAtPrice,
    ProductUnit unit,
    @Size(max = 40) String unitLabel,
    @Min(0) Integer stock,
    @Min(0) Integer lowStockThreshold,
    @Size(max = 120) String originRegion,
    @Size(max = 8) List<@NotBlank @Size(max = 500) String> imageUrls) {
}
