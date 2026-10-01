package mg.inmybush.api.auth;

import java.util.UUID;
import mg.inmybush.api.common.UnauthorizedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

/** Reads the authenticated user from the JWT in the security context (subject = user id). */
public final class CurrentUser {

    private CurrentUser() {
    }

    public static UUID id() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof Jwt jwt && jwt.getSubject() != null) {
            return UUID.fromString(jwt.getSubject());
        }
        throw new UnauthorizedException("Authentification requise.");
    }

    public static boolean hasRole(String role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null && auth.getAuthorities().stream().anyMatch(a -> ("ROLE_" + role).equals(a.getAuthority()));
    }
}
