package mg.inmybush.api.payment.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "payments")
public class Payment extends BaseEntity {

    @Column(name = "checkout_id", nullable = false, unique = true)
    private UUID checkoutId;

    @Enumerated(EnumType.STRING)
    @Column(name = "method", nullable = false, length = 20)
    private PaymentMethod method;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "amount", nullable = false)
    private long amount;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "provider_ref", length = 100)
    private String providerRef;

    protected Payment() {
    }

    public Payment(UUID checkoutId, PaymentMethod method, String phone, long amount) {
        this.checkoutId = checkoutId;
        this.method = method;
        this.phone = phone;
        this.amount = amount;
    }

    public UUID getCheckoutId() { return checkoutId; }

    public PaymentMethod getMethod() { return method; }

    public String getPhone() { return phone; }

    public long getAmount() { return amount; }

    public PaymentStatus getStatus() { return status; }

    public void setStatus(PaymentStatus status) { this.status = status; }

    public String getProviderRef() { return providerRef; }

    public void setProviderRef(String providerRef) { this.providerRef = providerRef; }
}
