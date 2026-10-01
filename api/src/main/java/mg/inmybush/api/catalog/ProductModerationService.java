package mg.inmybush.api.catalog;

import java.util.UUID;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.notification.NotificationContext;
import mg.inmybush.api.notification.NotificationService;
import mg.inmybush.api.notification.NotificationType;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Back-office moderation: products are reviewed within 24 h, then published or rejected with a reason. */
@Service
public class ProductModerationService {

    private final ProductRepository products;
    private final NotificationService notifications;

    public ProductModerationService(ProductRepository products, NotificationService notifications) {
        this.products = products;
        this.notifications = notifications;
    }

    @Transactional(readOnly = true)
    public PageResponse<SellerProductResponse> list(ProductStatus status, String q, int page, int size) {
        Specification<Product> spec = Specs.allOf(ProductSpecifications.hasStatus(status), ProductSpecifications.matchesText(q));
        Sort sort = status == ProductStatus.PENDING_REVIEW ? Sort.by(Sort.Order.asc("updatedAt")) : Sort.by(Sort.Order.desc("updatedAt"));
        return PageResponse.of(products.findAll(spec, Pages.of(page, size, sort)), ProductMapper::toSellerView);
    }

    @Transactional
    public SellerProductResponse approve(UUID productId) {
        Product p = require(productId);
        p.approve();
        notifications.notify(p.getShop().getOwner().getId(), NotificationContext.SALE, NotificationType.PRODUCT_APPROVED,
            "Produit publié", "« " + p.getName() + " » est maintenant en ligne.", "/vendre/produits/" + p.getId());
        return ProductMapper.toSellerView(p);
    }

    @Transactional
    public SellerProductResponse reject(UUID productId, String reason) {
        Product p = require(productId);
        p.reject(reason.trim());
        notifications.notify(p.getShop().getOwner().getId(), NotificationContext.SALE, NotificationType.PRODUCT_REJECTED,
            "Produit refusé", "« " + p.getName() + " » n'a pas été validé : " + reason.trim(), "/vendre/produits/" + p.getId());
        return ProductMapper.toSellerView(p);
    }

    private Product require(UUID productId) {
        return products.findWithShopById(productId).orElseThrow(() -> NotFoundException.of("Produit", productId));
    }
}
