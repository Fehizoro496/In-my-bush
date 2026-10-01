package mg.inmybush.api.auth.dto;

import jakarta.validation.constraints.NotBlank;

/** {@code identifier} is a phone number or an e-mail address. */
public record LoginRequest(@NotBlank String identifier, @NotBlank String password) {
}
