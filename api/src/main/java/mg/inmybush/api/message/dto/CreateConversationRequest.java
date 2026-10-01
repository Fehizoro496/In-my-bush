package mg.inmybush.api.message.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public record CreateConversationRequest(
    @NotNull UUID shopId,
    UUID productId,
    UUID orderId,
    @NotBlank @Size(max = 2000) String message) {
}
