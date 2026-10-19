package mg.inmybush.api.shop.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.entity.ShopStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ShopRepository extends JpaRepository<Shop, UUID>, JpaSpecificationExecutor<Shop> {

    @EntityGraph(attributePaths = "owner")
    Optional<Shop> findBySlug(String slug);

    @EntityGraph(attributePaths = "owner")
    Optional<Shop> findByOwnerId(UUID ownerId);

    @EntityGraph(attributePaths = "owner")
    Optional<Shop> findWithOwnerById(UUID id);

    @Override
    @EntityGraph(attributePaths = "owner")
    Page<Shop> findAll(Specification<Shop> spec, Pageable pageable);

    boolean existsBySlug(String slug);

    boolean existsByOwnerId(UUID ownerId);

    long countByStatus(ShopStatus status);

    @Query("select s from Shop s where s.status = :status and lower(s.name) like lower(concat('%', :q, '%')) order by s.ratingCount desc")
    List<Shop> searchByName(@Param("q") String q, @Param("status") ShopStatus status, Pageable pageable);
}
