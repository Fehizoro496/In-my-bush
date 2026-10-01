package mg.inmybush.api.payout;

import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PayoutRepository extends JpaRepository<Payout, UUID> {

    Page<Payout> findByShopId(UUID shopId, Pageable pageable);

    Page<Payout> findAllByOrderByCreatedAtDesc(Pageable pageable);
}
