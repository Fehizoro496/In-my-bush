package mg.inmybush.api.auth.dto;

/**
 * {@code auth} is set when an active account exists for the phone (passwordless login);
 * otherwise the client continues with /auth/register.
 */
public record OtpVerifyResponse(boolean verified, boolean accountExists, AuthResponse auth) {
}
