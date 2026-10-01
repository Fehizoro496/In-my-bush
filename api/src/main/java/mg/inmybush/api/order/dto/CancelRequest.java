package mg.inmybush.api.order.dto;

import jakarta.validation.constraints.Size;

public record CancelRequest(@Size(max = 500) String reason) {
}
