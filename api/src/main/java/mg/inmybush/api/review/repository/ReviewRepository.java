package mg.inmybush.api.review.repository;

import java.math.BigDecimal;
import java.util.UUID;
import mg.inmybush.api.review.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ReviewRepository extends JpaRepository<Review, UUID> {

    boolean existsByOrderIdAndProductId(UUID orderId, UUID productId);

    @Query(value = "select r from Review r join fetch r.product join fetch r.author where r.author.id = :authorId",
           countQuery = "select count(r) from Review r where r.author.id = :authorId")
    Page<Review> findByAuthorId(@Param("authorId") UUID authorId, Pageable pageable);

    @Query(value = "select r from Review r join fetch r.product join fetch r.author where r.product.shop.id = :shopId",
           countQuery = "select count(r) from Review r where r.product.shop.id = :shopId")
    Page<Review> findByShopId(@Param("shopId") UUID shopId, Pageable pageable);

    @Query("select coalesce(avg(r.rating), 0) from Review r where r.product.id = :productId")
    BigDecimal avgRatingByProduct(@Param("productId") UUID productId);

    @Query("select count(r) from Review r where r.product.id = :productId")
    int countByProductId(@Param("productId") UUID productId);

    @Query("select coalesce(avg(r.rating), 0) from Review r where r.product.shop.id = :shopId")
    BigDecimal avgRatingByShop(@Param("shopId") UUID shopId);

    @Query("select count(r) from Review r where r.product.shop.id = :shopId")
    int countByShopId(@Param("shopId") UUID shopId);

    @Query(value = "select r from Review r join fetch r.product join fetch r.author where r.product.id = :productId",
           countQuery = "select count(r) from Review r where r.product.id = :productId")
    Page<Review> findByProductId(@Param("productId") UUID productId, Pageable pageable);
}
