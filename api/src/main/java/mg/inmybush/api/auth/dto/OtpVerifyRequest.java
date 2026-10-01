package mg.inmybush.api.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record OtpVerifyRequest(@NotBlank String phone, @NotBlank @Pattern(regexp = "\\d{6}", message = "Code à 6 chiffres attendu.") String code) {
}
