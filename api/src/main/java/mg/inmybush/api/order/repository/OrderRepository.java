package mg.inmybush.api.order.repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.order.entity.Order;
import mg.inmybush.api.order.entity.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OrderRepository extends JpaRepository<Order, UUID> {

    @EntityGraph(attributePaths = {"buyer", "shop", "items"})
    Page<Order> findByBuyerId(UUID buyerId, Pageable pageable);

    @EntityGraph(attributePaths = {"buyer", "shop", "items"})
    Optional<Order> findByIdAndBuyerId(UUID id, UUID buyerId);

    @EntityGraph(attributePaths = {"buyer", "shop", "items"})
    Page<Order> findByShopId(UUID shopId, Pageable pageable);

    @EntityGraph(attributePaths = {"buyer", "shop", "items"})
    Page<Order> findByShopIdAndStatus(UUID shopId, OrderStatus status, Pageable pageable);

    @EntityGraph(attributePaths = {"buyer", "shop", "items"})
    Optional<Order> findByIdAndShopId(UUID id, UUID shopId);

    long countByStatus(OrderStatus status);

    @Query("select o from Order o where o.status = :status and o.acceptBefore < :now")
    List<Order> findExpiredPending(@Param("status") OrderStatus status, @Param("now") Instant now);

    @Query("select o from Order o where o.status = mg.inmybush.api.order.entity.OrderStatus.DELIVERED and o.deliveryConfirmedAt is null "
        + "and o.deliveredAt < :before")
    List<Order> findDeliveredUnconfirmed(@Param("before") Instant before);

    @Query("select coalesce(sum(o.total), 0) from Order o where o.status not in (mg.inmybush.api.order.entity.OrderStatus.CANCELLED, mg.inmybush.api.order.entity.OrderStatus.REFUSED)")
    long sumTotal();

    @Query("select coalesce(sum(o.commission), 0) from Order o where o.status not in (mg.inmybush.api.order.entity.OrderStatus.CANCELLED, mg.inmybush.api.order.entity.OrderStatus.REFUSED)")
    long sumCommission();

    List<Order> findByShopIdAndStatusAndPayoutIdIsNull(UUID shopId, OrderStatus status);

    @Query("select distinct o.shop.id from Order o where o.status = :status and o.payoutId is null")
    List<UUID> findShopIdsWithUnpaidOrders(@Param("status") OrderStatus status);

    @Query("select o.number from Order o where o.checkoutId = :checkoutId")
    List<String> findNumbersByCheckoutId(@Param("checkoutId") UUID checkoutId);

    @EntityGraph(attributePaths = {"buyer", "shop", "items"})
    @Query("select o from Order o")
    Page<Order> findAllWithDetails(Pageable pageable);
}
