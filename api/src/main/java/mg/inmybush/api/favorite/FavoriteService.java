package mg.inmybush.api.favorite;

import java.util.List;
import java.util.UUID;
import mg.inmybush.api.catalog.Product;
import mg.inmybush.api.catalog.ProductRepository;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.favorite.dto.FavoriteResponse;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FavoriteService {

    private final FavoriteRepository favorites;
    private final ProductRepository products;

    public FavoriteService(FavoriteRepository favorites, ProductRepository products) {
        this.favorites = favorites;
        this.products = products;
    }

    @Transactional(readOnly = true)
    public PageResponse<FavoriteResponse> list(UUID userId, int page, int size) {
        Page<Favorite> favPage = favorites.findByUserId(userId, Pages.newestFirst(page, size));
        List<FavoriteResponse> items = favPage.getContent().stream()
            .map(fav -> {
                Product p = products.findById(fav.getProductId()).orElse(null);
                if (p == null) return null;
                return new FavoriteResponse(p.getId(), p.getName(), p.getSlug(), p.getPrice(),
                    p.getMainImageUrl(), p.getShop().getName(), p.getShop().getSlug(), fav.getCreatedAt());
            })
            .filter(java.util.Objects::nonNull)
            .toList();
        return new PageResponse<>(items, favPage.getNumber(), favPage.getSize(),
            favPage.getTotalElements(), favPage.getTotalPages());
    }

    @Transactional
    public void add(UUID userId, UUID productId) {
        if (!products.existsById(productId)) {
            throw NotFoundException.of("Produit", productId);
        }
        if (!favorites.existsByUserIdAndProductId(userId, productId)) {
            favorites.save(new Favorite(userId, productId));
        }
    }

    @Transactional
    public void remove(UUID userId, UUID productId) {
        favorites.deleteByUserIdAndProductId(userId, productId);
    }
}
