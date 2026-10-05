package mg.inmybush.api.favorite.repository;

import java.util.UUID;
import mg.inmybush.api.favorite.entity.Favorite;
import mg.inmybush.api.favorite.entity.FavoriteId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FavoriteRepository extends JpaRepository<Favorite, FavoriteId> {

    Page<Favorite> findByUserId(UUID userId, Pageable pageable);

    boolean existsByUserIdAndProductId(UUID userId, UUID productId);

    void deleteByUserIdAndProductId(UUID userId, UUID productId);
}
