package mg.inmybush.api.shop.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.shop.dto.CreateShopRequest;
import mg.inmybush.api.shop.dto.ShopCreatedResponse;
import mg.inmybush.api.shop.dto.ShopResponse;
import mg.inmybush.api.shop.dto.UpdateShopRequest;
import mg.inmybush.api.shop.service.ShopService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/seller/shop")
@Tag(name = "Vendeur")
public class SellerShopController {

    private final ShopService shopService;

    public SellerShopController(ShopService shopService) {
        this.shopService = shopService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Ouvrir sa boutique (donne le rôle SELLER et renvoie de nouveaux jetons)")
    public ShopCreatedResponse create(@Valid @RequestBody CreateShopRequest request) {
        return shopService.create(CurrentUser.id(), request);
    }

    @GetMapping
    public ShopResponse get() {
        return shopService.getMine(CurrentUser.id());
    }

    @PatchMapping
    public ShopResponse update(@Valid @RequestBody UpdateShopRequest request) {
        return shopService.update(CurrentUser.id(), request);
    }
}
