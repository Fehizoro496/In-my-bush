package mg.inmybush.api.order.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RefuseRequest(@NotBlank @Size(max = 500) String reason) {
}
