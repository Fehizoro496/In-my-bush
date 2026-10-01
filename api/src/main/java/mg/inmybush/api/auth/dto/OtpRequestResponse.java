package mg.inmybush.api.auth.dto;

import java.time.Instant;

/** {@code devCode} is only filled when app.otp.expose-code=true (dev profile, no SMS gateway). */
public record OtpRequestResponse(String phone, Instant expiresAt, String devCode) {
}
