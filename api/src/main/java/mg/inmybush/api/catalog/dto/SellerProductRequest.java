package mg.inmybush.api.catalog.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.ProductUnit;

/** Create a product. With {@code submit=true} it goes straight to PENDING_REVIEW, otherwise it stays a DRAFT. */
public record SellerProductRequest(
    @NotBlank @Size(max = 160) String name,
    @NotNull UUID categoryId,
    @Size(max = 5000) String description,
    @NotNull @Positive Long price,
    @Positive Long compareAtPrice,
    @NotNull ProductUnit unit,
    @Size(max = 40) String unitLabel,
    @NotNull @Min(0) @Max(1_000_000) Integer stock,
    @Min(0) Integer lowStockThreshold,
    @Size(max = 120) String originRegion,
    @Size(max = 8) List<@NotBlank @Size(max = 500) String> imageUrls,
    Boolean submit) {
}
