package mg.inmybush.api.shop;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import mg.inmybush.api.catalog.ProductQueryService;
import mg.inmybush.api.catalog.dto.ProductSearchCriteria;
import mg.inmybush.api.catalog.dto.ProductSummaryResponse;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.shop.dto.ShopResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/shops")
@Tag(name = "Catalogue")
@SecurityRequirements
public class ShopController {

    private final ShopService shopService;
    private final ProductQueryService productQueryService;

    public ShopController(ShopService shopService, ProductQueryService productQueryService) {
        this.shopService = shopService;
        this.productQueryService = productQueryService;
    }

    @GetMapping("/{slug}")
    @Operation(summary = "Profil public d'une boutique")
    public ShopResponse get(@PathVariable String slug) {
        return shopService.getPublic(slug);
    }

    @GetMapping("/{slug}/products")
    @Operation(summary = "Produits publiés d'une boutique")
    public PageResponse<ProductSummaryResponse> products(@PathVariable String slug,
                                                         @RequestParam(required = false) String sort,
                                                         @RequestParam(defaultValue = "0") int page,
                                                         @RequestParam(defaultValue = "20") int size) {
        ProductSearchCriteria criteria = new ProductSearchCriteria(null, null, null, null, null, null, slug, sort);
        return productQueryService.search(criteria, page, size);
    }
}
