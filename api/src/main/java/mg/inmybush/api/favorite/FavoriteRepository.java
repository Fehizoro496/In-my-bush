package mg.inmybush.api.favorite;

import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FavoriteRepository extends JpaRepository<Favorite, FavoriteId> {

    Page<Favorite> findByUserId(UUID userId, Pageable pageable);

    boolean existsByUserIdAndProductId(UUID userId, UUID productId);

    void deleteByUserIdAndProductId(UUID userId, UUID productId);
}
