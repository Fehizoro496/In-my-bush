package mg.inmybush.api.catalog.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record StockUpdateRequest(@NotNull @Min(0) @Max(1_000_000) Integer stock, @Min(0) Integer lowStockThreshold) {
}
