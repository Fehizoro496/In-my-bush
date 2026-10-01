package mg.inmybush.api.checkout;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;
import mg.inmybush.api.order.DeliveryMode;

@Entity
@Table(name = "checkouts")
public class Checkout extends BaseEntity {

    @Column(name = "buyer_id", nullable = false)
    private UUID buyerId;

    @Column(name = "address_id")
    private UUID addressId;

    @Enumerated(EnumType.STRING)
    @Column(name = "delivery_mode", nullable = false, length = 10)
    private DeliveryMode deliveryMode;

    @Column(name = "recipient", length = 120)
    private String recipient;

    @Column(name = "delivery_phone", length = 20)
    private String deliveryPhone;

    @Column(name = "delivery_address", length = 600)
    private String deliveryAddress;

    @Column(name = "delivery_slot", length = 80)
    private String deliverySlot;

    @Column(name = "note", length = 500)
    private String note;

    @Column(name = "total", nullable = false)
    private long total;

    protected Checkout() {
    }

    public Checkout(UUID buyerId, DeliveryMode deliveryMode, long total) {
        this.buyerId = buyerId;
        this.deliveryMode = deliveryMode;
        this.total = total;
    }

    public UUID getBuyerId() { return buyerId; }

    public UUID getAddressId() { return addressId; }

    public void setAddressId(UUID addressId) { this.addressId = addressId; }

    public DeliveryMode getDeliveryMode() { return deliveryMode; }

    public String getRecipient() { return recipient; }

    public void setRecipient(String recipient) { this.recipient = recipient; }

    public String getDeliveryPhone() { return deliveryPhone; }

    public void setDeliveryPhone(String deliveryPhone) { this.deliveryPhone = deliveryPhone; }

    public String getDeliveryAddress() { return deliveryAddress; }

    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public String getDeliverySlot() { return deliverySlot; }

    public void setDeliverySlot(String deliverySlot) { this.deliverySlot = deliverySlot; }

    public String getNote() { return note; }

    public void setNote(String note) { this.note = note; }

    public long getTotal() { return total; }
}
