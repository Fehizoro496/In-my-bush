package mg.inmybush.api.catalog.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.catalog.dto.SellerProductRequest;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.catalog.dto.SellerProductUpdateRequest;
import mg.inmybush.api.catalog.dto.StockUpdateRequest;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.catalog.service.SellerProductService;
import mg.inmybush.api.common.PageResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/seller/products")
@Tag(name = "Vendeur")
public class SellerProductController {

    private final SellerProductService service;

    public SellerProductController(SellerProductService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Mes produits (hors archivés sauf si status=ARCHIVED)")
    public PageResponse<SellerProductResponse> list(@RequestParam(required = false) ProductStatus status,
                                                    @RequestParam(required = false) String q,
                                                    @RequestParam(defaultValue = "0") int page,
                                                    @RequestParam(defaultValue = "20") int size) {
        return service.list(CurrentUser.id(), status, q, page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Créer un produit (brouillon, ou soumis si submit=true)")
    public SellerProductResponse create(@Valid @RequestBody SellerProductRequest request) {
        return service.create(CurrentUser.id(), request);
    }

    @GetMapping("/{id}")
    public SellerProductResponse get(@PathVariable UUID id) {
        return service.get(CurrentUser.id(), id);
    }

    @PatchMapping("/{id}")
    public SellerProductResponse update(@PathVariable UUID id, @Valid @RequestBody SellerProductUpdateRequest request) {
        return service.update(CurrentUser.id(), id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Retirer un produit de la vente (archivage)")
    public void delete(@PathVariable UUID id) {
        service.archive(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/submit")
    @Operation(summary = "Soumettre à la validation In my bush")
    public SellerProductResponse submit(@PathVariable UUID id) {
        return service.submit(CurrentUser.id(), id);
    }

    @PatchMapping("/{id}/stock")
    public SellerProductResponse updateStock(@PathVariable UUID id, @Valid @RequestBody StockUpdateRequest request) {
        return service.updateStock(CurrentUser.id(), id, request);
    }
}
