package mg.inmybush.api.auth.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import mg.inmybush.api.user.repository.UserRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.filter.OncePerRequestFilter;

/** Checks current account state even when the access JWT has not expired. */
public class ActiveAccountFilter extends OncePerRequestFilter {
    private final UserRepository users;

    public ActiveAccountFilter(UserRepository users) { this.users = users; }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
        throws ServletException, IOException {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof JwtAuthenticationToken jwt) {
            boolean active;
            try {
                active = users.findById(UUID.fromString(jwt.getToken().getSubject()))
                    .map(u -> u.isActive()).orElse(false);
            } catch (IllegalArgumentException ex) {
                active = false;
            }
            if (!active) {
                SecurityContextHolder.clearContext();
                response.setStatus(401);
                response.setHeader("WWW-Authenticate", "Bearer");
                response.setContentType("application/problem+json");
                response.getWriter().write("{\"status\":401,\"title\":\"Session inactive\",\"code\":\"ACCOUNT_INACTIVE\"}");
                return;
            }
        }
        chain.doFilter(request, response);
    }
}
