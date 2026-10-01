package mg.inmybush.api.cart;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "carts")
public class Cart extends BaseEntity {

    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("createdAt ASC")
    private List<CartItem> items = new ArrayList<>();

    protected Cart() {
    }

    public Cart(UUID userId) {
        this.userId = userId;
    }

    public UUID getUserId() { return userId; }

    public List<CartItem> getItems() { return items; }

    public void addItem(CartItem item) {
        items.add(item);
    }

    public void clearItems() {
        items.clear();
    }
}
