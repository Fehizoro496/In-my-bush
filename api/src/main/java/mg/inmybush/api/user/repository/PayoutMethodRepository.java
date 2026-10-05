package mg.inmybush.api.user.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.user.entity.PayoutMethod;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PayoutMethodRepository extends JpaRepository<PayoutMethod, UUID> {

    List<PayoutMethod> findByUserIdOrderByIsDefaultDescCreatedAtAsc(UUID userId);

    Optional<PayoutMethod> findByIdAndUserId(UUID id, UUID userId);

    Optional<PayoutMethod> findFirstByUserIdOrderByIsDefaultDescCreatedAtAsc(UUID userId);
}
