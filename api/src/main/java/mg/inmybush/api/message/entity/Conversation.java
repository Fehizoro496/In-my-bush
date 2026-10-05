package mg.inmybush.api.message.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "conversations")
public class Conversation extends BaseEntity {

    @Column(name = "buyer_id", nullable = false)
    private UUID buyerId;

    @Column(name = "shop_id", nullable = false)
    private UUID shopId;

    @Column(name = "product_id")
    private UUID productId;

    @Column(name = "order_id")
    private UUID orderId;

    @Column(name = "last_message_at")
    private Instant lastMessageAt;

    @Column(name = "last_message_preview", length = 200)
    private String lastMessagePreview;

    protected Conversation() {
    }

    public Conversation(UUID buyerId, UUID shopId) {
        this.buyerId = buyerId;
        this.shopId = shopId;
    }

    public void updateLastMessage(String preview) {
        this.lastMessageAt = Instant.now();
        this.lastMessagePreview = preview != null && preview.length() > 200 ? preview.substring(0, 200) : preview;
    }

    public UUID getBuyerId() { return buyerId; }

    public UUID getShopId() { return shopId; }

    public UUID getProductId() { return productId; }

    public void setProductId(UUID productId) { this.productId = productId; }

    public UUID getOrderId() { return orderId; }

    public void setOrderId(UUID orderId) { this.orderId = orderId; }

    public Instant getLastMessageAt() { return lastMessageAt; }

    public String getLastMessagePreview() { return lastMessagePreview; }
}
