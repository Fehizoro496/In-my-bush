package mg.inmybush.api.user.dto;

import jakarta.validation.constraints.Size;

/** PATCH semantics: null fields are left unchanged. */
public record AddressUpdateRequest(
    @Size(max = 60) String label,
    @Size(min = 1, max = 120) String recipient,
    @Size(min = 1, max = 20) String phone,
    @Size(min = 1, max = 255) String line1,
    @Size(max = 120) String district,
    @Size(min = 1, max = 120) String city,
    @Size(max = 255) String landmark,
    Boolean isDefault) {
}
