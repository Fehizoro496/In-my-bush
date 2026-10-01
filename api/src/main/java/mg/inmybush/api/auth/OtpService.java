package mg.inmybush.api.auth;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import mg.inmybush.api.auth.dto.OtpRequestResponse;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.config.AppProperties;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** 6-digit one-time codes sent by SMS (stubbed). Codes are hashed, expire, and lock after 5 wrong attempts. */
@Service
public class OtpService {

    private static final Duration RESEND_DELAY = Duration.ofSeconds(60);

    private final OtpCodeRepository codes;
    private final SmsSender smsSender;
    private final AppProperties.Otp props;
    private final Clock clock;

    public OtpService(OtpCodeRepository codes, SmsSender smsSender, AppProperties appProperties, Clock clock) {
        this.codes = codes;
        this.smsSender = smsSender;
        this.props = appProperties.otp();
        this.clock = clock;
    }

    @Transactional
    public OtpRequestResponse request(String phone) {
        Instant now = clock.instant();
        codes.findFirstByPhoneOrderByCreatedAtDesc(phone).ifPresent(last -> {
            if (last.getCreatedAt() != null && last.getCreatedAt().plus(RESEND_DELAY).isAfter(now)) {
                throw new ConflictException("OTP_TOO_SOON", "Veuillez patienter une minute avant de redemander un code.");
            }
        });
        String code = TokenHasher.randomDigits(6);
        Instant expiresAt = now.plus(props.ttl());
        codes.save(new OtpCode(phone, hash(phone, code), expiresAt));
        smsSender.send(phone, "Votre code In my bush : " + code + ". Il expire dans " + props.ttl().toMinutes() + " min.");
        return new OtpRequestResponse(phone, expiresAt, props.exposeCode() ? code : null);
    }

    /** Throws when the code is wrong; wrong attempts are persisted (no rollback). */
    @Transactional(noRollbackFor = BadRequestException.class)
    public void verify(String phone, String code) {
        Instant now = clock.instant();
        OtpCode otp = codes.findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(phone)
            .orElseThrow(() -> new BadRequestException("OTP_EXPIRED", "Aucun code valide, veuillez en demander un nouveau."));
        if (!otp.getExpiresAt().isAfter(now)) {
            throw new BadRequestException("OTP_EXPIRED", "Le code a expiré, veuillez en demander un nouveau.");
        }
        if (otp.getAttempts() >= OtpCode.MAX_ATTEMPTS) {
            throw new BadRequestException("OTP_LOCKED", "Trop de tentatives, veuillez demander un nouveau code.");
        }
        if (!otp.getCodeHash().equals(hash(phone, code))) {
            otp.incrementAttempts();
            throw new BadRequestException("OTP_INVALID", "Code incorrect.");
        }
        otp.consume(now);
    }

    private static String hash(String phone, String code) {
        return TokenHasher.sha256(phone + ":" + code);
    }
}
