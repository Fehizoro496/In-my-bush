package mg.inmybush.api.checkout.repository;

import java.util.UUID;
import mg.inmybush.api.checkout.entity.Checkout;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CheckoutRepository extends JpaRepository<Checkout, UUID> {
}
