package mg.inmybush.api.cart;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "cart_items")
public class CartItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "cart_id", nullable = false)
    private Cart cart;

    @Column(name = "product_id", nullable = false)
    private UUID productId;

    @Column(name = "quantity", nullable = false)
    private int quantity;

    protected CartItem() {
    }

    public CartItem(Cart cart, UUID productId, int quantity) {
        this.cart = cart;
        this.productId = productId;
        this.quantity = quantity;
    }

    public Cart getCart() { return cart; }

    public UUID getProductId() { return productId; }

    public int getQuantity() { return quantity; }

    public void setQuantity(int quantity) { this.quantity = quantity; }
}
