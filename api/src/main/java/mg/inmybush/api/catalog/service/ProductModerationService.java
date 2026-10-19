package mg.inmybush.api.catalog.service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.catalog.repository.CategoryRepository;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.notification.entity.NotificationContext;
import mg.inmybush.api.notification.service.NotificationService;
import mg.inmybush.api.notification.entity.NotificationType;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import mg.inmybush.api.catalog.entity.Product;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.catalog.mapper.ProductMapper;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.catalog.repository.ProductSpecifications;
import mg.inmybush.api.catalog.repository.Specs;

/** Back-office moderation: products are reviewed within 24 h, then published or rejected with a reason. */
@Service
public class ProductModerationService {

    private final ProductRepository products;
    private final CategoryRepository categories;
    private final NotificationService notifications;

    public ProductModerationService(ProductRepository products, CategoryRepository categories, NotificationService notifications) {
        this.products = products;
        this.categories = categories;
        this.notifications = notifications;
    }

    /** A top-level {@code categoryId} also takes the products of its sub-categories. */
    @Transactional(readOnly = true)
    public PageResponse<SellerProductResponse> list(ProductStatus status, String q, UUID categoryId, UUID shopId, int page, int size) {
        Specification<Product> spec = Specs.allOf(ProductSpecifications.hasStatus(status), ProductSpecifications.matchesText(q),
            categoryId == null ? null : ProductSpecifications.inCategories(withChildren(categoryId)),
            shopId == null ? null : ProductSpecifications.ofShop(shopId));
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

    @Transactional
    public SellerProductResponse withdraw(UUID productId, String reason) {
        Product p = require(productId);
        p.withdraw(reason.trim());
        notifications.notify(p.getShop().getOwner().getId(), NotificationContext.SALE, NotificationType.PRODUCT_WITHDRAWN,
            "Produit retiré de la vente", "« " + p.getName() + " » a été retiré de la vente : " + reason.trim()
                + ". Corrigez la fiche pour la soumettre à nouveau.", "/vendre/produits/" + p.getId());
        return ProductMapper.toSellerView(p);
    }

    private List<UUID> withChildren(UUID categoryId) {
        List<UUID> ids = new ArrayList<>(List.of(categoryId));
        categories.findAllOrdered().stream()
            .filter(c -> c.getParent() != null && c.getParent().getId().equals(categoryId))
            .forEach(c -> ids.add(c.getId()));
        return ids;
    }

    private Product require(UUID productId) {
        return products.findWithShopById(productId).orElseThrow(() -> NotFoundException.of("Produit", productId));
    }
}
