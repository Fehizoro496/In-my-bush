package mg.inmybush.api.shop;

import java.util.UUID;
import mg.inmybush.api.auth.AuthService;
import mg.inmybush.api.catalog.ProductRepository;
import mg.inmybush.api.catalog.ProductStatus;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.common.ForbiddenException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.Slugs;
import mg.inmybush.api.shop.dto.CreateShopRequest;
import mg.inmybush.api.shop.dto.ShopCreatedResponse;
import mg.inmybush.api.shop.dto.ShopResponse;
import mg.inmybush.api.shop.dto.UpdateShopRequest;
import mg.inmybush.api.user.Role;
import mg.inmybush.api.user.User;
import mg.inmybush.api.user.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ShopService {

    private final ShopRepository shops;
    private final ProductRepository products;
    private final UserService userService;
    private final AuthService authService;

    public ShopService(ShopRepository shops, ProductRepository products, UserService userService, AuthService authService) {
        this.shops = shops;
        this.products = products;
        this.userService = userService;
        this.authService = authService;
    }

    /** Public shop page; suspended shops are hidden. */
    @Transactional(readOnly = true)
    public ShopResponse getPublic(String slug) {
        Shop shop = requirePublic(slug);
        return ShopResponse.from(shop, products.countByShopIdAndStatus(shop.getId(), ProductStatus.PUBLISHED));
    }

    @Transactional(readOnly = true)
    public Shop requirePublic(String slug) {
        Shop shop = shops.findBySlug(slug).orElseThrow(() -> NotFoundException.of("Boutique", slug));
        if (shop.getStatus() == ShopStatus.SUSPENDED) {
            throw NotFoundException.of("Boutique", slug);
        }
        return shop;
    }

    @Transactional(readOnly = true)
    public Shop requireMyShop(UUID userId) {
        return shops.findByOwnerId(userId)
            .orElseThrow(() -> new NotFoundException("Vous n'avez pas encore de boutique."));
    }

    @Transactional(readOnly = true)
    public ShopResponse getMine(UUID userId) {
        Shop shop = requireMyShop(userId);
        return ShopResponse.from(shop, products.countByShopIdAndStatus(shop.getId(), ProductStatus.PUBLISHED));
    }

    /** "Devenir vendeur": one shop per account; grants the SELLER role and returns fresh tokens. */
    @Transactional
    public ShopCreatedResponse create(UUID userId, CreateShopRequest req) {
        if (shops.existsByOwnerId(userId)) {
            throw new ConflictException("SHOP_EXISTS", "Vous avez déjà une boutique.");
        }
        User owner = userService.require(userId);
        Shop shop = new Shop(owner, req.name().trim(), uniqueSlug(req.name()));
        shop.setDescription(req.description());
        shop.setRegion(req.region().trim());
        shop.setCity(req.city().trim());
        shop.setLogoUrl(req.logoUrl());
        shop.setCoverUrl(req.coverUrl());
        shops.save(shop);
        owner.addRole(Role.SELLER);
        return new ShopCreatedResponse(ShopResponse.from(shop, 0), authService.issueTokens(owner));
    }

    @Transactional
    public ShopResponse update(UUID userId, UpdateShopRequest req) {
        Shop shop = requireMyShop(userId);
        if (req.name() != null) shop.setName(req.name().trim());
        if (req.description() != null) shop.setDescription(req.description());
        if (req.region() != null) shop.setRegion(req.region().trim());
        if (req.city() != null) shop.setCity(req.city().trim());
        if (req.logoUrl() != null) shop.setLogoUrl(req.logoUrl().isBlank() ? null : req.logoUrl());
        if (req.coverUrl() != null) shop.setCoverUrl(req.coverUrl().isBlank() ? null : req.coverUrl());
        if (req.status() != null && req.status() != shop.getStatus()) {
            if (shop.getStatus() == ShopStatus.SUSPENDED || req.status() == ShopStatus.SUSPENDED) {
                throw new ForbiddenException("SHOP_SUSPENDED", "Le statut d'une boutique suspendue est géré par In my bush.");
            }
            shop.setStatus(req.status());
        }
        return ShopResponse.from(shop, products.countByShopIdAndStatus(shop.getId(), ProductStatus.PUBLISHED));
    }

    private String uniqueSlug(String name) {
        String base = Slugs.slugify(name);
        String slug = base;
        int i = 2;
        while (shops.existsBySlug(slug)) {
            slug = base + "-" + i++;
        }
        return slug;
    }
}
