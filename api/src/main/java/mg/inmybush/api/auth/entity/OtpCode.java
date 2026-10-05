package mg.inmybush.api.auth.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.Instant;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "otp_codes")
public class OtpCode extends BaseEntity {

    public static final int MAX_ATTEMPTS = 5;

    @Column(name = "phone", nullable = false, length = 20)
    private String phone;

    @Column(name = "code_hash", nullable = false, length = 64)
    private String codeHash;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "consumed_at")
    private Instant consumedAt;

    @Column(name = "attempts", nullable = false)
    private int attempts;

    protected OtpCode() {
    }

    public OtpCode(String phone, String codeHash, Instant expiresAt) {
        this.phone = phone;
        this.codeHash = codeHash;
        this.expiresAt = expiresAt;
    }

    public String getPhone() { return phone; }

    public String getCodeHash() { return codeHash; }

    public Instant getExpiresAt() { return expiresAt; }

    public int getAttempts() { return attempts; }

    public void incrementAttempts() { attempts++; }

    public void consume(Instant now) { consumedAt = now; }
}
