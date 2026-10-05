package mg.inmybush.api.catalog.repository;

import jakarta.persistence.LockModeType;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.Product;
import mg.inmybush.api.catalog.entity.ProductStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductRepository extends JpaRepository<Product, UUID>, JpaSpecificationExecutor<Product> {

    /** Category counts for the category grid. */
    interface CategoryCount {
        UUID getCategoryId();

        long getCnt();
    }

    @Override
    @EntityGraph(attributePaths = {"shop", "category"})
    Page<Product> findAll(Specification<Product> spec, Pageable pageable);

    @EntityGraph(attributePaths = {"shop", "shop.owner", "category", "images"})
    Optional<Product> findBySlug(String slug);

    @EntityGraph(attributePaths = {"shop", "category", "images"})
    Optional<Product> findByIdAndShopId(UUID id, UUID shopId);

    @EntityGraph(attributePaths = {"shop", "shop.owner", "category"})
    Optional<Product> findWithShopById(UUID id);

    boolean existsBySlug(String slug);

    long countByShopIdAndStatus(UUID shopId, ProductStatus status);

    long countByStatus(ProductStatus status);

    long countByShopIdAndStatusAndStock(UUID shopId, ProductStatus status, int stock);

    @Query("select count(p) from Product p where p.shop.id = :shopId and p.status = :status "
        + "and p.stock > 0 and p.stock <= p.lowStockThreshold")
    long countLowStock(@Param("shopId") UUID shopId, @Param("status") ProductStatus status);

    @Query("select p.category.id as categoryId, count(p) as cnt from Product p "
        + "where p.status = :status and p.shop.status = mg.inmybush.api.shop.entity.ShopStatus.ACTIVE group by p.category.id")
    List<CategoryCount> countByCategory(@Param("status") ProductStatus status);

    /** Locks the rows in id order (deadlock-free) while checking out. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Product p where p.id in :ids order by p.id")
    List<Product> findAllByIdForUpdate(@Param("ids") Collection<UUID> ids);
}
