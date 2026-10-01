package mg.inmybush.api.user;

import java.util.Locale;
import java.util.UUID;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.user.dto.UpdateMeRequest;
import mg.inmybush.api.user.dto.UserResponse;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository users, PasswordEncoder passwordEncoder) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public User require(UUID id) {
        return users.findById(id).orElseThrow(() -> NotFoundException.of("Utilisateur", id));
    }

    @Transactional(readOnly = true)
    public UserResponse me(UUID userId) {
        return UserResponse.from(require(userId));
    }

    @Transactional
    public UserResponse updateMe(UUID userId, UpdateMeRequest req) {
        User user = require(userId);
        if (req.firstName() != null) user.setFirstName(req.firstName().trim());
        if (req.lastName() != null) user.setLastName(req.lastName().trim());
        if (req.avatarUrl() != null) user.setAvatarUrl(req.avatarUrl().isBlank() ? null : req.avatarUrl());
        if (req.email() != null) {
            String email = req.email().isBlank() ? null : req.email().trim().toLowerCase(Locale.ROOT);
            if (email != null && !email.equalsIgnoreCase(user.getEmail()) && users.existsByEmailIgnoreCase(email)) {
                throw new ConflictException("EMAIL_TAKEN", "Cette adresse e-mail est déjà utilisée.");
            }
            user.setEmail(email);
        }
        if (req.newPassword() != null) {
            if (req.currentPassword() == null || !passwordEncoder.matches(req.currentPassword(), user.getPasswordHash())) {
                throw new BadRequestException("WRONG_PASSWORD", "Le mot de passe actuel est incorrect.");
            }
            user.setPasswordHash(passwordEncoder.encode(req.newPassword()));
        }
        return UserResponse.from(user);
    }
}
