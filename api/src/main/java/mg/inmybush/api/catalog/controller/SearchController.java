package mg.inmybush.api.catalog.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import mg.inmybush.api.catalog.dto.SuggestionsResponse;
import mg.inmybush.api.catalog.service.ProductQueryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/search")
@Tag(name = "Catalogue")
@SecurityRequirements
public class SearchController {

    private final ProductQueryService productQueryService;

    public SearchController(ProductQueryService productQueryService) {
        this.productQueryService = productQueryService;
    }

    @GetMapping("/suggestions")
    @Operation(summary = "Suggestions de recherche (≥ 2 caractères)")
    public SuggestionsResponse suggestions(@RequestParam(required = false) String q) {
        return productQueryService.suggestions(q);
    }
}
