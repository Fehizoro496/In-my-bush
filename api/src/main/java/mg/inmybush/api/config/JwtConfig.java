package mg.inmybush.api.config;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

/** HS256 JWT encoder/decoder (Nimbus) sharing the secret from {@code app.jwt.secret}. */
@Configuration
public class JwtConfig {

    @Bean
    public SecretKey jwtSigningKey(AppProperties props) {
        return signingKey(props.jwt().secret());
    }

    @Bean
    public JwtDecoder jwtDecoder(SecretKey jwtSigningKey, AppProperties props) {
        return decoder(jwtSigningKey, props.jwt().issuer());
    }

    @Bean
    public JwtEncoder jwtEncoder(SecretKey jwtSigningKey) {
        return new NimbusJwtEncoder(new ImmutableSecret<>(jwtSigningKey));
    }

    @Bean
    public Clock clock() {
        return Clock.systemUTC();
    }

    public static SecretKey signingKey(String secret) {
        if (secret == null) {
            throw new IllegalStateException("app.jwt.secret must be set");
        }
        byte[] bytes = secret.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("app.jwt.secret must be at least 32 bytes for HS256");
        }
        return new SecretKeySpec(bytes, "HmacSHA256");
    }

    public static NimbusJwtDecoder decoder(SecretKey key, String issuer) {
        NimbusJwtDecoder decoder = NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();
        decoder.setJwtValidator(JwtValidators.createDefaultWithIssuer(issuer));
        return decoder;
    }
}
