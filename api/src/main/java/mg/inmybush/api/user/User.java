package mg.inmybush.api.user;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.Set;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "users")
public class User extends BaseEntity {

    @Column(name = "first_name", nullable = false, length = 80)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 80)
    private String lastName;

    @Column(name = "email", unique = true, length = 160)
    private String email;

    @Column(name = "phone", nullable = false, unique = true, length = 20)
    private String phone;

    @Column(name = "password_hash", nullable = false, length = 100)
    private String passwordHash;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private UserStatus status = UserStatus.ACTIVE;

    @Column(name = "phone_verified_at")
    private Instant phoneVerifiedAt;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, length = 20)
    private Set<Role> roles = new HashSet<>();

    protected User() {
    }

    public User(String firstName, String lastName, String email, String phone, String passwordHash) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.passwordHash = passwordHash;
        this.roles.add(Role.BUYER);
    }

    public String getFirstName() { return firstName; }

    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }

    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }

    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }

    public String getPasswordHash() { return passwordHash; }

    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getAvatarUrl() { return avatarUrl; }

    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public UserStatus getStatus() { return status; }

    public void setStatus(UserStatus status) { this.status = status; }

    public Instant getPhoneVerifiedAt() { return phoneVerifiedAt; }

    public void markPhoneVerified() { this.phoneVerifiedAt = Instant.now(); }

    public Set<Role> getRoles() {
        return roles.isEmpty() ? EnumSet.noneOf(Role.class) : EnumSet.copyOf(roles);
    }

    public boolean hasRole(Role role) { return roles.contains(role); }

    public void addRole(Role role) { roles.add(role); }

    public boolean isActive() { return status == UserStatus.ACTIVE; }

    /** "Fara N." — how a person is shown to other users. */
    public String getDisplayName() {
        return lastName == null || lastName.isBlank() ? firstName : firstName + " " + lastName.charAt(0) + ".";
    }

    public String getFullName() { return firstName + " " + lastName; }
}
