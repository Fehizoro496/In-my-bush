package mg.inmybush.api.shop.dto;

import mg.inmybush.api.auth.dto.AuthResponse;

/** The new token pair already carries the SELLER role, so the client can switch to the seller space at once. */
public record ShopCreatedResponse(ShopResponse shop, AuthResponse auth) {
}
