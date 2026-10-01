package mg.inmybush.api.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

/** PATCH /me — every field is optional; changing the password requires the current one. */
public record UpdateMeRequest(
    @Size(min = 1, max = 80) String firstName,
    @Size(min = 1, max = 80) String lastName,
    @Email @Size(max = 160) String email,
    @Size(max = 500) String avatarUrl,
    String currentPassword,
    @Size(min = 8, max = 72, message = "Le mot de passe doit contenir au moins 8 caractères.") String newPassword) {
}
