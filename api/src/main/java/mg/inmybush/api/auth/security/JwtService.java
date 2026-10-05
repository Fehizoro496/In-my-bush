package mg.inmybush.api.auth.security;

import java.time.Clock;
import java.time.Instant;
import java.util.List;
import mg.inmybush.api.auth.dto.IssuedToken;
import mg.inmybush.api.config.AppProperties;
import mg.inmybush.api.user.entity.User;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;

/** Issues short-lived HS256 access tokens: sub = user id, roles = ["BUYER", "SELLER", ...]. */
@Service
public class JwtService {

    private final JwtEncoder encoder;
    private final AppProperties.Jwt props;
    private final Clock clock;

    public JwtService(JwtEncoder encoder, AppProperties appProperties, Clock clock) {
        this.encoder = encoder;
        this.props = appProperties.jwt();
        this.clock = clock;
    }

    public IssuedToken createAccessToken(User user) {
        Instant now = clock.instant();
        Instant expiresAt = now.plus(props.accessTokenTtl());
        List<String> roles = user.getRoles().stream().map(Enum::name).sorted().toList();
        JwtClaimsSet claims = JwtClaimsSet.builder()
            .issuer(props.issuer())
            .issuedAt(now)
            .expiresAt(expiresAt)
            .subject(user.getId().toString())
            .claim("roles", roles)
            .claim("name", user.getFirstName())
            .build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
        String token = encoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
        return new IssuedToken(token, expiresAt);
    }
}
