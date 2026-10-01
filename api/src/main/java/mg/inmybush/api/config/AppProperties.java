package mg.inmybush.api.config;

import java.time.Duration;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

/** Application settings bound from the {@code app.*} keys (see application.yml, overridable with env vars). */
@ConfigurationProperties(prefix = "app")
public record AppProperties(Jwt jwt, Cors cors, Upload upload, Otp otp) {

    /** HMAC secret (≥ 32 bytes), issuer and token lifetimes. */
    public record Jwt(String secret, String issuer, Duration accessTokenTtl, Duration refreshTokenTtl) {
    }

    public record Cors(List<String> allowedOrigins) {
    }

    /** Local storage directory and the public base URL used to build file URLs. */
    public record Upload(String dir, String publicBaseUrl) {
    }

    /** OTP lifetime; {@code exposeCode} returns the code in the API response (dev only, no SMS gateway yet). */
    public record Otp(Duration ttl, boolean exposeCode) {
    }
}
