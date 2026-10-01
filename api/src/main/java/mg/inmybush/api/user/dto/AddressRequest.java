package mg.inmybush.api.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddressRequest(
    @Size(max = 60) String label,
    @NotBlank @Size(max = 120) String recipient,
    @NotBlank @Size(max = 20) String phone,
    @NotBlank @Size(max = 255) String line1,
    @Size(max = 120) String district,
    @NotBlank @Size(max = 120) String city,
    @Size(max = 255) String landmark,
    Boolean isDefault) {
}
