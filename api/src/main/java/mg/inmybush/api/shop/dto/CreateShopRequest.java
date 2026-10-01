package mg.inmybush.api.shop.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateShopRequest(
    @NotBlank @Size(min = 2, max = 120) String name,
    @Size(max = 2000) String description,
    @NotBlank @Size(max = 120) String region,
    @NotBlank @Size(max = 120) String city,
    @Size(max = 500) String logoUrl,
    @Size(max = 500) String coverUrl) {
}
