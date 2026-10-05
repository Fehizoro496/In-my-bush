package mg.inmybush.api.payout.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "payouts")
public class Payout extends BaseEntity {

    @Column(name = "shop_id", nullable = false)
    private UUID shopId;

    @Column(name = "amount", nullable = false)
    private long amount;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private PayoutStatus status = PayoutStatus.SCHEDULED;

    @Column(name = "method", length = 20)
    private String method;

    @Column(name = "phone_masked", length = 30)
    private String phoneMasked;

    @Column(name = "provider_ref", length = 100)
    private String providerRef;

    @Column(name = "period_start", nullable = false)
    private LocalDate periodStart;

    @Column(name = "period_end", nullable = false)
    private LocalDate periodEnd;

    @Column(name = "paid_at")
    private Instant paidAt;

    protected Payout() {
    }

    public Payout(UUID shopId, long amount, LocalDate periodStart, LocalDate periodEnd) {
        this.shopId = shopId;
        this.amount = amount;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
    }

    public void markPaid(String providerRef) {
        this.status = PayoutStatus.PAID;
        this.paidAt = Instant.now();
        this.providerRef = providerRef;
    }

    public void markFailed() {
        this.status = PayoutStatus.FAILED;
    }

    public UUID getShopId() { return shopId; }

    public long getAmount() { return amount; }

    public PayoutStatus getStatus() { return status; }

    public String getMethod() { return method; }

    public void setMethod(String method) { this.method = method; }

    public String getPhoneMasked() { return phoneMasked; }

    public void setPhoneMasked(String phoneMasked) { this.phoneMasked = phoneMasked; }

    public String getProviderRef() { return providerRef; }

    public LocalDate getPeriodStart() { return periodStart; }

    public LocalDate getPeriodEnd() { return periodEnd; }

    public Instant getPaidAt() { return paidAt; }
}
