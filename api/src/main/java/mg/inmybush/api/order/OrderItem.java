package mg.inmybush.api.order;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "order_items")
public class OrderItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "product_id")
    private UUID productId;

    @Column(name = "product_name", nullable = false, length = 160)
    private String productName;

    @Column(name = "product_slug", length = 200)
    private String productSlug;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "unit_price", nullable = false)
    private long unitPrice;

    @Column(name = "unit_label", length = 40)
    private String unitLabel;

    @Column(name = "quantity", nullable = false)
    private int quantity;

    @Column(name = "line_total", nullable = false)
    private long lineTotal;

    protected OrderItem() {
    }

    public OrderItem(Order order, UUID productId, String productName, String productSlug,
                     String imageUrl, long unitPrice, String unitLabel, int quantity) {
        this.order = order;
        this.productId = productId;
        this.productName = productName;
        this.productSlug = productSlug;
        this.imageUrl = imageUrl;
        this.unitPrice = unitPrice;
        this.unitLabel = unitLabel;
        this.quantity = quantity;
        this.lineTotal = unitPrice * quantity;
    }

    public Order getOrder() { return order; }

    public UUID getProductId() { return productId; }

    public String getProductName() { return productName; }

    public String getProductSlug() { return productSlug; }

    public String getImageUrl() { return imageUrl; }

    public long getUnitPrice() { return unitPrice; }

    public String getUnitLabel() { return unitLabel; }

    public int getQuantity() { return quantity; }

    public long getLineTotal() { return lineTotal; }
}
