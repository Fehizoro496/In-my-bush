package mg.inmybush.api.catalog.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RejectProductRequest(@NotBlank @Size(max = 500) String reason) {
}
