package mg.inmybush.api.admin.service;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminShopDetailResponse;
import mg.inmybush.api.admin.dto.AdminShopResponse;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.report.entity.TargetType;
import mg.inmybush.api.report.repository.ReportRepository;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.entity.ShopStatus;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Shops as the backoffice manages them. A suspended shop disappears from the catalogue and its products can
 * no longer be added to a cart nor ordered; orders already placed are left as they are.
 */
@Service
public class AdminShopService {

    private final ShopRepository shops;
    private final ProductRepository products;
    private final OrderRepository orders;
    private final ReportRepository reports;
    private final AuditService audit;
    private final ModerationNotifier notifier;

    public AdminShopService(ShopRepository shops, ProductRepository products, OrderRepository orders,
                            ReportRepository reports, AuditService audit, ModerationNotifier notifier) {
        this.shops = shops;
        this.products = products;
        this.orders = orders;
        this.reports = reports;
        this.audit = audit;
        this.notifier = notifier;
    }

    /** {@code q} looks in the name and city of the shop and in the name of its owner. */
    @Transactional(readOnly = true)
    public PageResponse<AdminShopResponse> list(ShopStatus status, String q, int page, int size) {
        Specification<Shop> spec = (root, query, cb) -> {
            var predicates = new ArrayList<Predicate>();
            if (status != null) predicates.add(cb.equal(root.get("status"), status));
            if (q != null && !q.isBlank()) {
                String term = "%" + q.trim().toLowerCase(Locale.ROOT)
                    .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
                Join<Shop, User> owner = root.join("owner");
                predicates.add(cb.or(cb.like(cb.lower(root.get("name")), term, '\\'),
                    cb.like(cb.lower(root.get("city")), term, '\\'),
                    cb.like(cb.lower(owner.get("firstName")), term, '\\'),
                    cb.like(cb.lower(owner.get("lastName")), term, '\\')));
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
        Page<Shop> found = shops.findAll(spec, Pages.newestFirst(page, size));
        Map<UUID, Map<ProductStatus, Long>> counts = productCounts(found.map(Shop::getId).toList());
        return PageResponse.of(found, s -> AdminShopResponse.from(s, counts.getOrDefault(s.getId(), emptyCounts())));
    }

    @Transactional(readOnly = true)
    public AdminShopDetailResponse get(UUID id) {
        Shop shop = require(id);
        return new AdminShopDetailResponse(view(shop), orders.countByShopId(id),
            reports.countByTargetTypeAndTargetId(TargetType.SHOP, id), audit.history("SHOP", id));
    }

    @Transactional
    public AdminShopResponse suspend(UUID id, String reason) {
        Shop shop = require(id);
        if (shop.getStatus() == ShopStatus.SUSPENDED) {
            throw new ConflictException("INVALID_SHOP_STATUS", "Cette boutique est déjà suspendue.");
        }
        shop.setStatus(ShopStatus.SUSPENDED);
        audit.record("SHOP_SUSPENDED", "SHOP", id, reason.trim());
        notifier.shopSuspended(shop, reason.trim());
        return view(shop);
    }

    @Transactional
    public AdminShopResponse reactivate(UUID id) {
        Shop shop = require(id);
        if (shop.getStatus() != ShopStatus.SUSPENDED) {
            throw new ConflictException("INVALID_SHOP_STATUS", "Seule une boutique suspendue peut être réactivée.");
        }
        shop.setStatus(ShopStatus.ACTIVE);
        audit.record("SHOP_REACTIVATED", "SHOP", id, null);
        notifier.shopReactivated(shop);
        return view(shop);
    }

    private Shop require(UUID id) {
        return shops.findWithOwnerById(id).orElseThrow(() -> NotFoundException.of("Boutique", id));
    }

    private AdminShopResponse view(Shop shop) {
        return AdminShopResponse.from(shop, productCounts(List.of(shop.getId())).getOrDefault(shop.getId(), emptyCounts()));
    }

    /** Products of each shop by status, every status present even when it counts none. */
    private Map<UUID, Map<ProductStatus, Long>> productCounts(List<UUID> shopIds) {
        Map<UUID, Map<ProductStatus, Long>> counts = new HashMap<>();
        if (shopIds.isEmpty()) return counts;
        for (var c : products.countByShopAndStatus(shopIds)) {
            counts.computeIfAbsent(c.getShopId(), k -> emptyCounts()).put(c.getStatus(), c.getCnt());
        }
        return counts;
    }

    private static Map<ProductStatus, Long> emptyCounts() {
        Map<ProductStatus, Long> counts = new EnumMap<>(ProductStatus.class);
        for (ProductStatus s : ProductStatus.values()) counts.put(s, 0L);
        return counts;
    }
}
