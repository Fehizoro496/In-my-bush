package mg.inmybush.api.auth.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import mg.inmybush.api.auth.dto.AuthResponse;
import mg.inmybush.api.auth.dto.LoginRequest;
import mg.inmybush.api.auth.dto.OtpRequest;
import mg.inmybush.api.auth.dto.OtpRequestResponse;
import mg.inmybush.api.auth.dto.RefreshRequest;
import mg.inmybush.api.auth.dto.RegisterRequest;
import mg.inmybush.api.auth.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Auth", description = "Inscription, connexion et jetons")
@SecurityRequirements
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register/otp")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Inscription, étape 1 : envoyer un code à 6 chiffres par SMS au numéro à vérifier")
    public OtpRequestResponse requestRegistrationOtp(@Valid @RequestBody OtpRequest request) {
        return authService.requestRegistrationOtp(request.phone());
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Inscription, étape 2 : créer le compte (rôle BUYER) avec le code reçu et ouvrir une session")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    @Operation(summary = "Connexion par téléphone ou e-mail + mot de passe")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    @Operation(summary = "Échanger un refresh token contre une nouvelle paire de jetons (rotation)")
    public AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return authService.refresh(request.refreshToken());
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Révoquer le refresh token")
    public void logout(@Valid @RequestBody RefreshRequest request) {
        authService.logout(request.refreshToken());
    }
}
