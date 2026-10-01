package mg.inmybush.api.admin.dto;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import mg.inmybush.api.user.Role;
import mg.inmybush.api.user.User;
import mg.inmybush.api.user.UserStatus;

public record AdminUserResponse(
    UUID id,
    String firstName,
    String lastName,
    String email,
    String phone,
    String avatarUrl,
    UserStatus status,
    Set<Role> roles,
    Instant createdAt) {

    public static AdminUserResponse from(User u) {
        return new AdminUserResponse(u.getId(), u.getFirstName(), u.getLastName(), u.getEmail(),
            u.getPhone(), u.getAvatarUrl(), u.getStatus(), u.getRoles(), u.getCreatedAt());
    }
}
