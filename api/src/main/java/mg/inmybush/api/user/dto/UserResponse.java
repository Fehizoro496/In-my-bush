package mg.inmybush.api.user.dto;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import mg.inmybush.api.user.Role;
import mg.inmybush.api.user.User;
import mg.inmybush.api.user.UserStatus;

public record UserResponse(
    UUID id,
    String firstName,
    String lastName,
    String email,
    String phone,
    String avatarUrl,
    Set<Role> roles,
    UserStatus status,
    boolean phoneVerified,
    Instant createdAt) {

    public static UserResponse from(User u) {
        return new UserResponse(u.getId(), u.getFirstName(), u.getLastName(), u.getEmail(), u.getPhone(), u.getAvatarUrl(),
            u.getRoles(), u.getStatus(), u.getPhoneVerifiedAt() != null, u.getCreatedAt());
    }
}
