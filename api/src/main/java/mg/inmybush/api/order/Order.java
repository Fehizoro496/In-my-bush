package mg.inmybush.api.order;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.payment.PaymentStatus;
import mg.inmybush.api.shop.Shop;
import mg.inmybush.api.user.User;

@Entity
@Table(name = "orders")
public class Order extends BaseEntity {

    @Column(name = "number", nullable = false, unique = true, length = 20)
    private String number;

    @Column(name = "checkout_id", nullable = false)
    private UUID checkoutId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "buyer_id", nullable = false)
    private User buyer;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private OrderStatus status = OrderStatus.PENDING_CONFIRMATION;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false, length = 20)
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "delivery_mode", nullable = false, length = 10)
    private DeliveryMode deliveryMode;

    @Column(name = "subtotal", nullable = false)
    private long subtotal;

    @Column(name = "delivery_fee", nullable = false)
    private long deliveryFee;

    @Column(name = "discount", nullable = false)
    private long discount;

    @Column(name = "commission", nullable = false)
    private long commission;

    @Column(name = "total", nullable = false)
    private long total;

    @Column(name = "seller_net", nullable = false)
    private long sellerNet;

    @Column(name = "delivery_slot", length = 80)
    private String deliverySlot;

    @Column(name = "accept_before", nullable = false)
    private Instant acceptBefore;

    @Column(name = "delivered_at")
    private Instant deliveredAt;

    @Column(name = "delivery_confirmed_at")
    private Instant deliveryConfirmedAt;

    @Column(name = "cancel_reason", length = 500)
    private String cancelReason;

    @Column(name = "payout_id")
    private UUID payoutId;

    @Version
    @Column(name = "version", nullable = false)
    private long version;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("createdAt ASC")
    private List<OrderItem> items = new ArrayList<>();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("createdAt ASC")
    private List<OrderEvent> events = new ArrayList<>();

    protected Order() {
    }

    public Order(String number, UUID checkoutId, User buyer, Shop shop, DeliveryMode deliveryMode,
                 long subtotal, long deliveryFee, long discount, long commission, long total, long sellerNet,
                 Instant acceptBefore) {
        this.number = number;
        this.checkoutId = checkoutId;
        this.buyer = buyer;
        this.shop = shop;
        this.deliveryMode = deliveryMode;
        this.subtotal = subtotal;
        this.deliveryFee = deliveryFee;
        this.discount = discount;
        this.commission = commission;
        this.total = total;
        this.sellerNet = sellerNet;
        this.acceptBefore = acceptBefore;
        addEvent(OrderStatus.PENDING_CONFIRMATION, null);
    }

    // ------------------------------------------------------------------ lifecycle

    public void accept() {
        requireStatus(OrderStatus.PENDING_CONFIRMATION);
        transition(OrderStatus.ACCEPTED, null);
    }

    public void refuse(String reason) {
        requireStatus(OrderStatus.PENDING_CONFIRMATION);
        transition(OrderStatus.REFUSED, reason);
        this.cancelReason = reason;
    }

    public void prepare() {
        requireStatus(OrderStatus.ACCEPTED);
        transition(OrderStatus.PREPARED, null);
    }

    public void ship() {
        requireStatus(OrderStatus.PREPARED);
        transition(OrderStatus.IN_DELIVERY, null);
    }

    public void deliver() {
        if (status != OrderStatus.IN_DELIVERY && status != OrderStatus.PREPARED) {
            throw invalidStatus();
        }
        transition(OrderStatus.DELIVERED, null);
        this.deliveredAt = Instant.now();
    }

    public void confirmDelivery() {
        requireStatus(OrderStatus.DELIVERED);
        this.deliveryConfirmedAt = Instant.now();
    }

    public void cancel(String reason) {
        if (status == OrderStatus.DELIVERED || status == OrderStatus.CANCELLED || status == OrderStatus.REFUSED) {
            throw invalidStatus();
        }
        transition(OrderStatus.CANCELLED, reason);
        this.cancelReason = reason;
    }

    private void transition(OrderStatus to, String note) {
        this.status = to;
        addEvent(to, note);
    }

    private void requireStatus(OrderStatus expected) {
        if (status != expected) throw invalidStatus();
    }

    private ConflictException invalidStatus() {
        return new ConflictException("INVALID_ORDER_STATUS",
            "Action impossible : la commande est au statut " + status + ".");
    }

    private void addEvent(OrderStatus eventStatus, String note) {
        events.add(new OrderEvent(this, eventStatus, note));
    }

    // ------------------------------------------------------------------ accessors

    public String getNumber() { return number; }

    public UUID getCheckoutId() { return checkoutId; }

    public User getBuyer() { return buyer; }

    public Shop getShop() { return shop; }

    public OrderStatus getStatus() { return status; }

    public PaymentStatus getPaymentStatus() { return paymentStatus; }

    public void setPaymentStatus(PaymentStatus paymentStatus) { this.paymentStatus = paymentStatus; }

    public DeliveryMode getDeliveryMode() { return deliveryMode; }

    public long getSubtotal() { return subtotal; }

    public long getDeliveryFee() { return deliveryFee; }

    public long getDiscount() { return discount; }

    public long getCommission() { return commission; }

    public long getTotal() { return total; }

    public long getSellerNet() { return sellerNet; }

    public String getDeliverySlot() { return deliverySlot; }

    public void setDeliverySlot(String deliverySlot) { this.deliverySlot = deliverySlot; }

    public Instant getAcceptBefore() { return acceptBefore; }

    public Instant getDeliveredAt() { return deliveredAt; }

    public Instant getDeliveryConfirmedAt() { return deliveryConfirmedAt; }

    public String getCancelReason() { return cancelReason; }

    public UUID getPayoutId() { return payoutId; }

    public void setPayoutId(UUID payoutId) { this.payoutId = payoutId; }

    public List<OrderItem> getItems() { return items; }

    public List<OrderEvent> getEvents() { return events; }

    public void addItem(OrderItem item) { items.add(item); }
}
