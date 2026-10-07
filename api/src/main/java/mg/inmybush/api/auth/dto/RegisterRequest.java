package mg.inmybush.api.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
    @NotBlank @Size(max = 80) String firstName,
    @NotBlank @Size(max = 80) String lastName,
    @NotBlank @Size(max = 20) String phone,
    @Email @Size(max = 160) String email,
    @NotBlank @Size(min = 8, max = 72, message = "Le mot de passe doit contenir au moins 8 caractères.") String password,
    @NotBlank @Pattern(regexp = "\\d{6}", message = "Code à 6 chiffres attendu.") String otpCode) {
}
