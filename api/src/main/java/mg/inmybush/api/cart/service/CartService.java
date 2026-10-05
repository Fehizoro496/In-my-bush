package mg.inmybush.api.cart.service;

import java.util.List;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.Product;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.cart.dto.AddCartItemRequest;
import mg.inmybush.api.cart.dto.CartItemResponse;
import mg.inmybush.api.cart.dto.CartResponse;
import mg.inmybush.api.cart.dto.UpdateCartItemRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import mg.inmybush.api.cart.entity.Cart;
import mg.inmybush.api.cart.entity.CartItem;
import mg.inmybush.api.cart.repository.CartItemRepository;
import mg.inmybush.api.cart.repository.CartRepository;

@Service
public class CartService {

    private final CartRepository carts;
    private final CartItemRepository cartItems;
    private final ProductRepository products;

    public CartService(CartRepository carts, CartItemRepository cartItems, ProductRepository products) {
        this.carts = carts;
        this.cartItems = cartItems;
        this.products = products;
    }

    @Transactional(readOnly = true)
    public CartResponse get(UUID userId) {
        Cart cart = carts.findByUserId(userId).orElse(null);
        if (cart == null) {
            return new CartResponse(List.of(), 0, 0);
        }
        List<CartItemResponse> items = cart.getItems().stream().map(this::toResponse).toList();
        long total = items.stream().filter(CartItemResponse::available).mapToLong(CartItemResponse::lineTotal).sum();
        return new CartResponse(items, total, items.size());
    }

    @Transactional
    public CartResponse addItem(UUID userId, AddCartItemRequest req) {
        Product product = products.findById(req.productId())
            .orElseThrow(() -> NotFoundException.of("Produit", req.productId()));
        Cart cart = carts.findByUserId(userId).orElseGet(() -> carts.save(new Cart(userId)));
        CartItem existing = cartItems.findByCartIdAndProductId(cart.getId(), req.productId()).orElse(null);
        if (existing != null) {
            existing.setQuantity(existing.getQuantity() + req.quantity());
        } else {
            cart.addItem(new CartItem(cart, req.productId(), req.quantity()));
        }
        carts.flush();
        return get(userId);
    }

    @Transactional
    public CartResponse updateItem(UUID userId, UUID itemId, UpdateCartItemRequest req) {
        Cart cart = requireCart(userId);
        CartItem item = cart.getItems().stream()
            .filter(ci -> ci.getId().equals(itemId)).findFirst()
            .orElseThrow(() -> NotFoundException.of("Article du panier", itemId));
        item.setQuantity(req.quantity());
        return get(userId);
    }

    @Transactional
    public void removeItem(UUID userId, UUID itemId) {
        Cart cart = requireCart(userId);
        cart.getItems().removeIf(ci -> ci.getId().equals(itemId));
    }

    @Transactional
    public void clear(UUID userId) {
        carts.findByUserId(userId).ifPresent(cart -> cart.clearItems());
    }

    public Cart requireCart(UUID userId) {
        return carts.findByUserId(userId)
            .orElseThrow(() -> new NotFoundException("Votre panier est vide."));
    }

    private CartItemResponse toResponse(CartItem item) {
        Product p = products.findById(item.getProductId()).orElse(null);
        if (p == null) {
            return new CartItemResponse(item.getId(), item.getProductId(), "(produit supprimé)", null,
                0, null, item.getQuantity(), 0, false);
        }
        boolean available = p.isPurchasable() && p.getStock() >= item.getQuantity();
        return new CartItemResponse(item.getId(), p.getId(), p.getName(), p.getSlug(), p.getPrice(),
            p.getMainImageUrl(), item.getQuantity(), p.getPrice() * item.getQuantity(), available);
    }
}
