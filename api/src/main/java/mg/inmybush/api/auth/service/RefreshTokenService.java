package mg.inmybush.api.auth.service;

import java.time.Clock;
import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.auth.dto.IssuedToken;
import mg.inmybush.api.auth.entity.RefreshToken;
import mg.inmybush.api.auth.repository.RefreshTokenRepository;
import mg.inmybush.api.auth.security.TokenHasher;
import mg.inmybush.api.common.UnauthorizedException;
import mg.inmybush.api.config.AppProperties;
import mg.inmybush.api.user.entity.User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Opaque, rotating refresh tokens stored as SHA-256 hashes. Re-using an already rotated token revokes every
 * session of the user (token theft detection).
 */
@Service
public class RefreshTokenService {

    public record Rotation(User user, IssuedToken refreshToken) {
    }

    private final RefreshTokenRepository tokens;
    private final AppProperties.Jwt props;
    private final Clock clock;

    public RefreshTokenService(RefreshTokenRepository tokens, AppProperties appProperties, Clock clock) {
        this.tokens = tokens;
        this.props = appProperties.jwt();
        this.clock = clock;
    }

    @Transactional
    public IssuedToken issue(User user) {
        String raw = TokenHasher.randomToken();
        Instant expiresAt = clock.instant().plus(props.refreshTokenTtl());
        tokens.save(new RefreshToken(user, TokenHasher.sha256(raw), expiresAt));
        return new IssuedToken(raw, expiresAt);
    }

    @Transactional(noRollbackFor = UnauthorizedException.class)
    public Rotation rotate(String rawToken) {
        Instant now = clock.instant();
        RefreshToken token = tokens.findByTokenHash(TokenHasher.sha256(rawToken))
            .orElseThrow(() -> new UnauthorizedException("Session invalide, veuillez vous reconnecter."));
        if (token.isRevoked()) {
            tokens.revokeAllForUser(token.getUser().getId(), now);
            throw new UnauthorizedException("Session expirée, veuillez vous reconnecter.");
        }
        if (token.isExpired(now)) {
            throw new UnauthorizedException("Session expirée, veuillez vous reconnecter.");
        }
        token.revoke(now);
        return new Rotation(token.getUser(), issue(token.getUser()));
    }

    @Transactional
    public void revoke(String rawToken) {
        tokens.findByTokenHash(TokenHasher.sha256(rawToken)).ifPresent(t -> t.revoke(clock.instant()));
    }

    @Transactional
    public void revokeAll(UUID userId) {
        tokens.revokeAllForUser(userId, clock.instant());
    }
}
