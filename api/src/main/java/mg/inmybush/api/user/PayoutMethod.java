package mg.inmybush.api.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;
import mg.inmybush.api.common.PhoneNumbers;
import mg.inmybush.api.payment.PaymentMethod;

/** Mobile Money account on which a seller receives payouts. The full number is never returned by the API. */
@Entity
@Table(name = "payout_methods")
public class PayoutMethod extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "method", nullable = false, length = 20)
    private PaymentMethod method;

    @Column(name = "phone", nullable = false, length = 20)
    private String phone;

    @Column(name = "phone_masked", nullable = false, length = 30)
    private String phoneMasked;

    @Column(name = "is_default", nullable = false)
    private boolean isDefault;

    protected PayoutMethod() {
    }

    public PayoutMethod(UUID userId, PaymentMethod method, String phone) {
        this.userId = userId;
        this.method = method;
        this.phone = phone;
        this.phoneMasked = PhoneNumbers.mask(phone);
    }

    public UUID getUserId() { return userId; }

    public PaymentMethod getMethod() { return method; }

    public String getPhone() { return phone; }

    public String getPhoneMasked() { return phoneMasked; }

    public boolean isDefault() { return isDefault; }

    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }
}
