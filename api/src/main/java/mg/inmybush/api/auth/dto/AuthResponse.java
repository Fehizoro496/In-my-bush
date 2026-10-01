package mg.inmybush.api.auth.dto;

import java.time.Instant;
import mg.inmybush.api.user.dto.UserResponse;

public record AuthResponse(
    String tokenType,
    String accessToken,
    Instant accessTokenExpiresAt,
    String refreshToken,
    Instant refreshTokenExpiresAt,
    UserResponse user) {
}
