package mg.inmybush.api.catalog.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import mg.inmybush.api.catalog.dto.ProductDetailResponse;
import mg.inmybush.api.catalog.dto.ProductSearchCriteria;
import mg.inmybush.api.catalog.dto.ProductSummaryResponse;
import mg.inmybush.api.catalog.service.ProductQueryService;
import mg.inmybush.api.common.PageResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/products")
@Tag(name = "Catalogue")
@SecurityRequirements
public class ProductController {

    private final ProductQueryService productQueryService;

    public ProductController(ProductQueryService productQueryService) {
        this.productQueryService = productQueryService;
    }

    @GetMapping
    @Operation(summary = "Rechercher / filtrer / trier les produits publiés")
    public PageResponse<ProductSummaryResponse> search(
        @RequestParam(required = false) String q,
        @Parameter(description = "Slug de catégorie (sous-catégories incluses)") @RequestParam(required = false) String category,
        @RequestParam(required = false) String region,
        @RequestParam(required = false) Long minPrice,
        @RequestParam(required = false) Long maxPrice,
        @RequestParam(required = false) Boolean inStock,
        @Parameter(description = "Slug de boutique") @RequestParam(required = false) String shop,
        @Parameter(description = "newest | price_asc | price_desc | rating | popular") @RequestParam(required = false) String sort,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size) {
        ProductSearchCriteria criteria = new ProductSearchCriteria(q, category, region, minPrice, maxPrice, inStock, shop, sort);
        return productQueryService.search(criteria, page, size);
    }

    @GetMapping("/{slug}")
    @Operation(summary = "Fiche produit")
    public ProductDetailResponse get(@PathVariable String slug) {
        return productQueryService.getBySlug(slug);
    }
}
