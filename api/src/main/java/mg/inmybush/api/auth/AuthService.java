package mg.inmybush.api.auth;

import java.util.Locale;
import java.util.Optional;
import mg.inmybush.api.auth.dto.AuthResponse;
import mg.inmybush.api.auth.dto.LoginRequest;
import mg.inmybush.api.auth.dto.OtpRequestResponse;
import mg.inmybush.api.auth.dto.OtpVerifyResponse;
import mg.inmybush.api.auth.dto.RegisterRequest;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.common.ForbiddenException;
import mg.inmybush.api.common.PhoneNumbers;
import mg.inmybush.api.common.UnauthorizedException;
import mg.inmybush.api.user.User;
import mg.inmybush.api.user.UserRepository;
import mg.inmybush.api.user.UserStatus;
import mg.inmybush.api.user.dto.UserResponse;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokens;
    private final OtpService otpService;

    public AuthService(UserRepository users, PasswordEncoder passwordEncoder, JwtService jwtService,
                       RefreshTokenService refreshTokens, OtpService otpService) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokens = refreshTokens;
        this.otpService = otpService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        String phone = PhoneNumbers.normalize(req.phone());
        if (users.existsByPhone(phone)) {
            throw new ConflictException("PHONE_TAKEN", "Un compte existe déjà avec ce numéro.");
        }
        String email = normalizeEmail(req.email());
        if (email != null && users.existsByEmailIgnoreCase(email)) {
            throw new ConflictException("EMAIL_TAKEN", "Un compte existe déjà avec cette adresse e-mail.");
        }
        User user = new User(req.firstName().trim(), req.lastName().trim(), email, phone, passwordEncoder.encode(req.password()));
        users.save(user);
        return issueTokens(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest req) {
        Optional<User> found = findByIdentifier(req.identifier().trim());
        User user = found.filter(u -> passwordEncoder.matches(req.password(), u.getPasswordHash()))
            .orElseThrow(() -> new UnauthorizedException("Identifiant ou mot de passe incorrect."));
        ensureActive(user);
        return issueTokens(user);
    }

    @Transactional(noRollbackFor = UnauthorizedException.class)
    public AuthResponse refresh(String refreshToken) {
        RefreshTokenService.Rotation rotation = refreshTokens.rotate(refreshToken);
        User user = rotation.user();
        ensureActive(user);
        IssuedToken access = jwtService.createAccessToken(user);
        return new AuthResponse("Bearer", access.value(), access.expiresAt(), rotation.refreshToken().value(),
            rotation.refreshToken().expiresAt(), UserResponse.from(user));
    }

    @Transactional
    public void logout(String refreshToken) {
        refreshTokens.revoke(refreshToken);
    }

    public OtpRequestResponse requestOtp(String rawPhone) {
        return otpService.request(PhoneNumbers.normalize(rawPhone));
    }

    @Transactional(noRollbackFor = BadRequestException.class)
    public OtpVerifyResponse verifyOtp(String rawPhone, String code) {
        String phone = PhoneNumbers.normalize(rawPhone);
        otpService.verify(phone, code);
        Optional<User> user = users.findByPhone(phone);
        if (user.isEmpty()) {
            return new OtpVerifyResponse(true, false, null);
        }
        User u = user.get();
        u.markPhoneVerified();
        ensureActive(u);
        return new OtpVerifyResponse(true, true, issueTokens(u));
    }

    /** Issues a fresh token pair, e.g. after the user got a new role (opening a shop). */
    @Transactional
    public AuthResponse issueTokens(User user) {
        IssuedToken access = jwtService.createAccessToken(user);
        IssuedToken refresh = refreshTokens.issue(user);
        return new AuthResponse("Bearer", access.value(), access.expiresAt(), refresh.value(), refresh.expiresAt(),
            UserResponse.from(user));
    }

    private Optional<User> findByIdentifier(String identifier) {
        if (identifier.contains("@")) {
            return users.findByEmailIgnoreCase(identifier);
        }
        if (PhoneNumbers.looksLikePhone(identifier)) {
            try {
                return users.findByPhone(PhoneNumbers.normalize(identifier));
            } catch (BadRequestException e) {
                return Optional.empty();
            }
        }
        return Optional.empty();
    }

    private static void ensureActive(User user) {
        if (user.getStatus() == UserStatus.SUSPENDED) {
            throw new ForbiddenException("ACCOUNT_SUSPENDED", "Votre compte est suspendu. Contactez le support In my bush.");
        }
        if (user.getStatus() == UserStatus.BANNED) {
            throw new ForbiddenException("ACCOUNT_BANNED", "Votre compte a été désactivé.");
        }
    }

    private static String normalizeEmail(String email) {
        return email == null || email.isBlank() ? null : email.trim().toLowerCase(Locale.ROOT);
    }
}
