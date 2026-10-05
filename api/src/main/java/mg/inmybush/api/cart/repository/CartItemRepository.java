package mg.inmybush.api.cart.repository;

import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.cart.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CartItemRepository extends JpaRepository<CartItem, UUID> {

    Optional<CartItem> findByCartIdAndProductId(UUID cartId, UUID productId);
}
