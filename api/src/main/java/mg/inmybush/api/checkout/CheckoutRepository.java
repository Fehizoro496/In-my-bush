package mg.inmybush.api.checkout;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CheckoutRepository extends JpaRepository<Checkout, UUID> {
}
