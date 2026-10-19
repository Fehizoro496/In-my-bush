package mg.inmybush.api.auth.service;

import java.time.Clock;
import java.time.Duration;
import java.sql.Timestamp;
import mg.inmybush.api.auth.security.TokenHasher;
import mg.inmybush.api.common.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthRateLimiter {
    private final JdbcTemplate jdbc;
    private final Clock clock;
    public AuthRateLimiter(JdbcTemplate jdbc, Clock clock) { this.jdbc = jdbc; this.clock = clock; }

    /** Independent transaction so rejected login attempts remain counted. Keys contain no plaintext PII. */
    @Transactional(propagation = Propagation.REQUIRES_NEW, noRollbackFor = ApiException.class)
    public void check(String key, int limit, Duration window) {
        var now = clock.instant();
        Integer count = jdbc.queryForObject("""
            INSERT INTO auth_rate_limits (key_hash, attempts, expires_at) VALUES (?, 1, ?)
            ON CONFLICT (key_hash) DO UPDATE SET
              attempts = CASE WHEN auth_rate_limits.expires_at <= ? THEN 1 ELSE auth_rate_limits.attempts + 1 END,
              expires_at = CASE WHEN auth_rate_limits.expires_at <= ? THEN EXCLUDED.expires_at ELSE auth_rate_limits.expires_at END
            RETURNING attempts
            """, Integer.class, TokenHasher.sha256(key), Timestamp.from(now.plus(window)),
            Timestamp.from(now), Timestamp.from(now));
        if (count != null && count > limit) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, "RATE_LIMITED",
                "Trop de tentatives. Veuillez réessayer plus tard.");
        }
    }

    @Scheduled(fixedDelay = 3600000)
    public void cleanup() {
        jdbc.update("DELETE FROM auth_rate_limits WHERE expires_at < ?", Timestamp.from(clock.instant()));
    }
}
