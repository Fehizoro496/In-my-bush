package mg.inmybush.api.auth.dto;

import java.time.Instant;

public record IssuedToken(String value, Instant expiresAt) {
}
