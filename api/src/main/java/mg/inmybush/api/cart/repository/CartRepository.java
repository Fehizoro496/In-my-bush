package mg.inmybush.api.cart.repository;

import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.cart.entity.Cart;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CartRepository extends JpaRepository<Cart, UUID> {

    Optional<Cart> findByUserId(UUID userId);
}
