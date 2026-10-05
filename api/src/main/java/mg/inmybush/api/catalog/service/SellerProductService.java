package mg.inmybush.api.catalog.service;

import java.util.Objects;
import java.util.UUID;
import mg.inmybush.api.catalog.dto.SellerProductRequest;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.catalog.dto.SellerProductUpdateRequest;
import mg.inmybush.api.catalog.dto.StockUpdateRequest;
import mg.inmybush.api.catalog.entity.Category;
import mg.inmybush.api.catalog.entity.Product;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.catalog.mapper.ProductMapper;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.catalog.repository.ProductSpecifications;
import mg.inmybush.api.catalog.repository.Specs;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.common.Slugs;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.service.ShopService;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Seller space: product CRUD, submission to moderation and stock. */
@Service
public class SellerProductService {

    private final ProductRepository products;
    private final ShopService shopService;
    private final CategoryService categoryService;

    public SellerProductService(ProductRepository products, ShopService shopService, CategoryService categoryService) {
        this.products = products;
        this.shopService = shopService;
        this.categoryService = categoryService;
    }

    @Transactional(readOnly = true)
    public PageResponse<SellerProductResponse> list(UUID userId, ProductStatus status, String q, int page, int size) {
        Shop shop = shopService.requireMyShop(userId);
        Specification<Product> spec = Specs.allOf(
            ProductSpecifications.ofShop(shop.getId()),
            status == null ? ProductSpecifications.notArchived() : ProductSpecifications.hasStatus(status),
            ProductSpecifications.matchesText(q));
        return PageResponse.of(products.findAll(spec, Pages.of(page, size, Sort.by(Sort.Order.desc("updatedAt")))),
            ProductMapper::toSellerView);
    }

    @Transactional(readOnly = true)
    public SellerProductResponse get(UUID userId, UUID productId) {
        return ProductMapper.toSellerView(requireOwned(userId, productId));
    }

    @Transactional
    public SellerProductResponse create(UUID userId, SellerProductRequest req) {
        Shop shop = shopService.requireMyShop(userId);
        validatePrices(req.price(), req.compareAtPrice());
        Category category = categoryService.require(req.categoryId());
        Product p = new Product(shop, category, req.name().trim(), uniqueSlug(req.name()));
        p.setDescription(req.description());
        p.setPrice(req.price());
        p.setCompareAtPrice(req.compareAtPrice());
        p.setUnit(req.unit());
        p.setUnitLabel(req.unitLabel());
        p.setStock(req.stock());
        if (req.lowStockThreshold() != null) p.setLowStockThreshold(req.lowStockThreshold());
        p.setOriginRegion(req.originRegion() != null ? req.originRegion() : shop.getRegion());
        p.replaceImages(req.imageUrls());
        if (Boolean.TRUE.equals(req.submit())) {
            p.submitForReview();
        }
        return ProductMapper.toSellerView(products.save(p));
    }

    @Transactional
    public SellerProductResponse update(UUID userId, UUID productId, SellerProductUpdateRequest req) {
        Product p = requireOwned(userId, productId);
        boolean contentChanged = false;
        if (req.name() != null && !req.name().trim().equals(p.getName())) {
            p.setName(req.name().trim());
            contentChanged = true;
        }
        if (req.description() != null && !req.description().equals(p.getDescription())) {
            p.setDescription(req.description());
            contentChanged = true;
        }
        if (req.categoryId() != null && !req.categoryId().equals(p.getCategory().getId())) {
            p.setCategory(categoryService.require(req.categoryId()));
            contentChanged = true;
        }
        if (req.imageUrls() != null && !Objects.equals(req.imageUrls(), p.getImageUrls())) {
            p.replaceImages(req.imageUrls());
            contentChanged = true;
        }
        if (req.price() != null) p.setPrice(req.price());
        if (req.compareAtPrice() != null) p.setCompareAtPrice(req.compareAtPrice() == 0 ? null : req.compareAtPrice());
        validatePrices(p.getPrice(), p.getCompareAtPrice());
        if (req.unit() != null) p.setUnit(req.unit());
        if (req.unitLabel() != null) p.setUnitLabel(req.unitLabel());
        if (req.stock() != null) p.setStock(req.stock());
        if (req.lowStockThreshold() != null) p.setLowStockThreshold(req.lowStockThreshold());
        if (req.originRegion() != null) p.setOriginRegion(req.originRegion());
        if (contentChanged) {
            p.markContentChanged();
        }
        return ProductMapper.toSellerView(p);
    }

    /** "Retirer de la vente": products are archived, never hard-deleted (orders reference them). */
    @Transactional
    public void archive(UUID userId, UUID productId) {
        requireOwned(userId, productId).archive();
    }

    @Transactional
    public SellerProductResponse submit(UUID userId, UUID productId) {
        Product p = requireOwned(userId, productId);
        p.submitForReview();
        return ProductMapper.toSellerView(p);
    }

    @Transactional
    public SellerProductResponse updateStock(UUID userId, UUID productId, StockUpdateRequest req) {
        Product p = requireOwned(userId, productId);
        p.setStock(req.stock());
        if (req.lowStockThreshold() != null) p.setLowStockThreshold(req.lowStockThreshold());
        return ProductMapper.toSellerView(p);
    }

    private Product requireOwned(UUID userId, UUID productId) {
        Shop shop = shopService.requireMyShop(userId);
        return products.findByIdAndShopId(productId, shop.getId()).orElseThrow(() -> NotFoundException.of("Produit", productId));
    }

    private static void validatePrices(Long price, Long compareAtPrice) {
        if (compareAtPrice != null && price != null && compareAtPrice <= price) {
            throw new BadRequestException("INVALID_COMPARE_PRICE", "Le prix barré doit être supérieur au prix de vente.");
        }
    }

    private String uniqueSlug(String name) {
        String base = Slugs.slugify(name);
        String slug = base;
        int i = 2;
        while (products.existsBySlug(slug)) {
            slug = base + "-" + i++;
        }
        return slug;
    }
}
