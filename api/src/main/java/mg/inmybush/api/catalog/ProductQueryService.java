package mg.inmybush.api.catalog;

import java.util.List;
import java.util.Set;
import java.util.UUID;
import mg.inmybush.api.catalog.dto.ProductDetailResponse;
import mg.inmybush.api.catalog.dto.ProductSearchCriteria;
import mg.inmybush.api.catalog.dto.ProductSummaryResponse;
import mg.inmybush.api.catalog.dto.SuggestionsResponse;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.shop.ShopRepository;
import mg.inmybush.api.shop.ShopStatus;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Public, read-only catalogue: search, filters, sort, product page and suggestions. */
@Service
@Transactional(readOnly = true)
public class ProductQueryService {

    private final ProductRepository products;
    private final CategoryService categoryService;
    private final CategoryRepository categories;
    private final ShopRepository shops;

    public ProductQueryService(ProductRepository products, CategoryService categoryService, CategoryRepository categories,
                               ShopRepository shops) {
        this.products = products;
        this.categoryService = categoryService;
        this.categories = categories;
        this.shops = shops;
    }

    public PageResponse<ProductSummaryResponse> search(ProductSearchCriteria c, int page, int size) {
        if (c.minPrice() != null && c.maxPrice() != null && c.minPrice() > c.maxPrice()) {
            throw new BadRequestException("INVALID_PRICE_RANGE", "Le prix minimum dépasse le prix maximum.");
        }
        Set<UUID> categoryIds = c.category() == null || c.category().isBlank() ? null : categoryService.idsWithDescendants(c.category());
        Specification<Product> spec = Specs.allOf(
            ProductSpecifications.publiclyVisible(),
            ProductSpecifications.matchesText(c.q()),
            ProductSpecifications.inCategories(categoryIds),
            ProductSpecifications.inRegion(c.region()),
            ProductSpecifications.priceBetween(c.minPrice(), c.maxPrice()),
            ProductSpecifications.inStock(c.inStock()),
            ProductSpecifications.ofShopSlug(c.shop()));
        Pageable pageable = Pages.of(page, size, ProductSort.parse(c.sort()).toSort());
        return PageResponse.of(products.findAll(spec, pageable), ProductMapper::toSummary);
    }

    public ProductDetailResponse getBySlug(String slug) {
        Product p = products.findBySlug(slug)
            .filter(prod -> prod.getStatus() == ProductStatus.PUBLISHED && prod.getShop().getStatus() != ShopStatus.SUSPENDED)
            .orElseThrow(() -> NotFoundException.of("Produit", slug));
        return ProductMapper.toDetail(p);
    }

    public SuggestionsResponse suggestions(String q) {
        if (q == null || q.trim().length() < 2) {
            return SuggestionsResponse.empty();
        }
        String term = q.trim();
        Specification<Product> spec = Specs.allOf(ProductSpecifications.publiclyVisible(), ProductSpecifications.matchesText(term));
        List<SuggestionsResponse.Item> productItems = products
            .findAll(spec, PageRequest.of(0, 5, Sort.by(Sort.Order.desc("ratingCount"))))
            .map(p -> new SuggestionsResponse.Item(p.getId(), p.getSlug(), p.getName(), p.getMainImageUrl()))
            .getContent();
        List<SuggestionsResponse.Item> categoryItems = categories.searchByName(term, PageRequest.of(0, 3)).stream()
            .map(c -> new SuggestionsResponse.Item(c.getId(), c.getSlug(), c.getName(), null))
            .toList();
        List<SuggestionsResponse.Item> shopItems = shops.searchByName(term, ShopStatus.ACTIVE, PageRequest.of(0, 3)).stream()
            .map(s -> new SuggestionsResponse.Item(s.getId(), s.getSlug(), s.getName(), s.getLogoUrl()))
            .toList();
        return new SuggestionsResponse(productItems, categoryItems, shopItems);
    }
}
