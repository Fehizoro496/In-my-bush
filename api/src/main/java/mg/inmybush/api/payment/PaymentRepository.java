package mg.inmybush.api.payment;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    Optional<Payment> findByCheckoutId(UUID checkoutId);

    Page<Payment> findAllByOrderByCreatedAtDesc(Pageable pageable);
}
