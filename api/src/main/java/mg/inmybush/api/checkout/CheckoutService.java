package mg.inmybush.api.checkout;

import jakarta.persistence.EntityManager;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import mg.inmybush.api.cart.Cart;
import mg.inmybush.api.cart.CartItem;
import mg.inmybush.api.cart.CartService;
import mg.inmybush.api.catalog.Product;
import mg.inmybush.api.catalog.ProductRepository;
import mg.inmybush.api.checkout.dto.CheckoutRequest;
import mg.inmybush.api.checkout.dto.CheckoutResponse;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.order.DeliveryMode;
import mg.inmybush.api.order.Order;
import mg.inmybush.api.order.OrderItem;
import mg.inmybush.api.order.OrderRepository;
import mg.inmybush.api.payment.PaymentService;
import mg.inmybush.api.settings.PricingSettings;
import mg.inmybush.api.settings.SettingsService;
import mg.inmybush.api.shop.Shop;
import mg.inmybush.api.user.Address;
import mg.inmybush.api.user.AddressService;
import mg.inmybush.api.user.User;
import mg.inmybush.api.user.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CheckoutService {

    private final CheckoutRepository checkouts;
    private final CartService cartService;
    private final ProductRepository products;
    private final OrderRepository orders;
    private final PaymentService paymentService;
    private final UserService userService;
    private final AddressService addressService;
    private final SettingsService settingsService;
    private final EntityManager em;

    public CheckoutService(CheckoutRepository checkouts, CartService cartService, ProductRepository products,
                           OrderRepository orders, PaymentService paymentService, UserService userService,
                           AddressService addressService, SettingsService settingsService, EntityManager em) {
        this.checkouts = checkouts;
        this.cartService = cartService;
        this.products = products;
        this.orders = orders;
        this.paymentService = paymentService;
        this.userService = userService;
        this.addressService = addressService;
        this.settingsService = settingsService;
        this.em = em;
    }

    @Transactional
    public CheckoutResponse checkout(UUID userId, CheckoutRequest req) {
        User buyer = userService.require(userId);
        Cart cart = cartService.requireCart(userId);
        if (cart.getItems().isEmpty()) {
            throw new BadRequestException("EMPTY_CART", "Votre panier est vide.");
        }

        PricingSettings pricing = settingsService.pricing();
        int acceptHours = settingsService.sellerAcceptHours();

        // resolve delivery address
        Address address = null;
        if (req.deliveryMode() == DeliveryMode.HOME) {
            if (req.addressId() == null) {
                throw new BadRequestException("ADDRESS_REQUIRED", "Adresse de livraison requise pour la livraison à domicile.");
            }
            address = addressService.require(userId, req.addressId());
        }

        // lock products and decrement stock
        List<UUID> productIds = cart.getItems().stream().map(CartItem::getProductId).toList();
        List<Product> locked = products.findAllByIdForUpdate(productIds);
        Map<UUID, Product> productMap = new LinkedHashMap<>();
        locked.forEach(p -> productMap.put(p.getId(), p));

        // group items by shop
        Map<UUID, List<CartItem>> byShop = new LinkedHashMap<>();
        for (CartItem ci : cart.getItems()) {
            Product p = productMap.get(ci.getProductId());
            if (p == null || !p.isPurchasable()) {
                throw new BadRequestException("UNAVAILABLE_PRODUCT", "Le produit « " + (p != null ? p.getName() : ci.getProductId()) + " » n'est plus disponible.");
            }
            p.decrementStock(ci.getQuantity());
            byShop.computeIfAbsent(p.getShop().getId(), k -> new ArrayList<>()).add(ci);
        }

        // compute totals
        long grandTotal = 0;
        for (List<CartItem> shopItems : byShop.values()) {
            for (CartItem ci : shopItems) {
                Product p = productMap.get(ci.getProductId());
                grandTotal += p.getPrice() * ci.getQuantity();
            }
        }

        long deliveryFee = 0;
        if (req.deliveryMode() == DeliveryMode.HOME) {
            if (pricing.freeDeliveryThreshold() == 0 || grandTotal < pricing.freeDeliveryThreshold()) {
                deliveryFee = pricing.deliveryFee();
            }
        }

        long checkoutTotal = grandTotal + deliveryFee;

        Checkout checkout = new Checkout(userId, req.deliveryMode(), checkoutTotal);
        if (address != null) {
            checkout.setAddressId(address.getId());
            checkout.setRecipient(address.getRecipient());
            checkout.setDeliveryPhone(address.getPhone());
            checkout.setDeliveryAddress(address.toSingleLine());
        }
        checkout.setDeliverySlot(req.deliverySlot());
        checkout.setNote(req.note());
        checkout = checkouts.save(checkout);

        // create payment
        paymentService.create(checkout.getId(), req.paymentMethod(), req.paymentPhone(), checkoutTotal);

        // create one order per shop
        Instant acceptBefore = Instant.now().plus(acceptHours, ChronoUnit.HOURS);
        List<UUID> orderIds = new ArrayList<>();

        for (var entry : byShop.entrySet()) {
            Shop shop = productMap.get(entry.getValue().get(0).getProductId()).getShop();
            long subtotal = 0;
            for (CartItem ci : entry.getValue()) {
                Product p = productMap.get(ci.getProductId());
                subtotal += p.getPrice() * ci.getQuantity();
            }
            long commission = pricing.commissionRate().multiply(BigDecimal.valueOf(subtotal)).longValue();
            long shopDeliveryFee = byShop.size() == 1 ? deliveryFee : 0;
            long orderTotal = subtotal + shopDeliveryFee;
            long sellerNet = subtotal - commission;

            String orderNumber = generateOrderNumber();
            Order order = new Order(orderNumber, checkout.getId(), buyer, shop, req.deliveryMode(),
                subtotal, shopDeliveryFee, 0, commission, orderTotal, sellerNet, acceptBefore);
            order.setDeliverySlot(req.deliverySlot());

            for (CartItem ci : entry.getValue()) {
                Product p = productMap.get(ci.getProductId());
                order.addItem(new OrderItem(order, p.getId(), p.getName(), p.getSlug(),
                    p.getMainImageUrl(), p.getPrice(), p.getUnitLabel(), ci.getQuantity()));
            }
            orders.save(order);
            orderIds.add(order.getId());
        }

        // clear cart
        cart.clearItems();

        return new CheckoutResponse(checkout.getId(), orderIds, checkoutTotal);
    }

    private String generateOrderNumber() {
        long seq = ((Number) em.createNativeQuery("SELECT nextval('order_number_seq')").getSingleResult()).longValue();
        return "IMB-" + String.format("%06d", seq);
    }
}
