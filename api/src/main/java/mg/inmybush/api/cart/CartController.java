package mg.inmybush.api.cart;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import mg.inmybush.api.auth.CurrentUser;
import mg.inmybush.api.cart.dto.AddCartItemRequest;
import mg.inmybush.api.cart.dto.CartResponse;
import mg.inmybush.api.cart.dto.UpdateCartItemRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me/cart")
@Tag(name = "Me")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    @Operation(summary = "Contenu du panier")
    public CartResponse get() {
        return cartService.get(CurrentUser.id());
    }

    @PostMapping("/items")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Ajouter un article au panier")
    public CartResponse addItem(@Valid @RequestBody AddCartItemRequest request) {
        return cartService.addItem(CurrentUser.id(), request);
    }

    @PatchMapping("/items/{id}")
    @Operation(summary = "Modifier la quantité d'un article")
    public CartResponse updateItem(@PathVariable UUID id, @Valid @RequestBody UpdateCartItemRequest request) {
        return cartService.updateItem(CurrentUser.id(), id, request);
    }

    @DeleteMapping("/items/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Retirer un article du panier")
    public void removeItem(@PathVariable UUID id) {
        cartService.removeItem(CurrentUser.id(), id);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Vider le panier")
    public void clear() {
        cartService.clear(CurrentUser.id());
    }
}
