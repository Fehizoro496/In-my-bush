package mg.inmybush.api.review.service;

import java.math.BigDecimal;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.Product;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.common.ForbiddenException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.order.entity.Order;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.order.entity.OrderStatus;
import mg.inmybush.api.review.dto.CreateReviewRequest;
import mg.inmybush.api.review.dto.ReviewResponse;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.shop.service.ShopService;
import mg.inmybush.api.user.entity.User;
import mg.inmybush.api.user.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import mg.inmybush.api.review.entity.Review;
import mg.inmybush.api.review.repository.ReviewRepository;

@Service
public class ReviewService {

    private final ReviewRepository reviews;
    private final OrderRepository orders;
    private final ProductRepository products;
    private final ShopRepository shopRepository;
    private final UserService userService;
    private final ShopService shopService;

    public ReviewService(ReviewRepository reviews, OrderRepository orders, ProductRepository products,
                         ShopRepository shopRepository, UserService userService, ShopService shopService) {
        this.reviews = reviews;
        this.orders = orders;
        this.products = products;
        this.shopRepository = shopRepository;
        this.userService = userService;
        this.shopService = shopService;
    }

    @Transactional
    public ReviewResponse create(UUID userId, UUID orderId, CreateReviewRequest req) {
        User author = userService.require(userId);
        Order order = orders.findByIdAndBuyerId(orderId, userId)
            .orElseThrow(() -> NotFoundException.of("Commande", orderId));
        if (order.getStatus() != OrderStatus.DELIVERED) {
            throw new ForbiddenException("ORDER_NOT_DELIVERED", "Vous ne pouvez noter que les commandes livrées.");
        }
        Product product = products.findById(req.productId())
            .orElseThrow(() -> NotFoundException.of("Produit", req.productId()));
        if (reviews.existsByOrderIdAndProductId(orderId, req.productId())) {
            throw new ConflictException("REVIEW_EXISTS", "Vous avez déjà laissé un avis pour ce produit sur cette commande.");
        }
        Review review = new Review(product, order, author, req.rating(), req.comment());
        reviews.save(review);
        updateProductRating(product.getId());
        updateShopRating(product.getShop().getId());
        return ReviewResponse.from(review);
    }

    @Transactional(readOnly = true)
    public PageResponse<ReviewResponse> myReviews(UUID userId, int page, int size) {
        return PageResponse.of(reviews.findByAuthorId(userId, Pages.newestFirst(page, size)), ReviewResponse::from);
    }

    @Transactional(readOnly = true)
    public PageResponse<ReviewResponse> shopReviews(UUID userId, int page, int size) {
        Shop shop = shopService.requireMyShop(userId);
        return PageResponse.of(reviews.findByShopId(shop.getId(), Pages.newestFirst(page, size)), ReviewResponse::from);
    }

    @Transactional(readOnly = true)
    public PageResponse<ReviewResponse> productReviews(UUID productId, int page, int size) {
        return PageResponse.of(reviews.findByProductId(productId, Pages.newestFirst(page, size)), ReviewResponse::from);
    }

    @Transactional
    public ReviewResponse reply(UUID userId, UUID reviewId, String reply) {
        Shop shop = shopService.requireMyShop(userId);
        Review review = reviews.findById(reviewId)
            .orElseThrow(() -> NotFoundException.of("Avis", reviewId));
        if (!review.getProduct().getShop().getId().equals(shop.getId())) {
            throw new ForbiddenException("Cet avis ne concerne pas votre boutique.");
        }
        review.reply(reply);
        return ReviewResponse.from(review);
    }

    private void updateProductRating(UUID productId) {
        BigDecimal avg = reviews.avgRatingByProduct(productId);
        int count = reviews.countByProductId(productId);
        Product product = products.findById(productId).orElse(null);
        if (product != null) product.updateRating(avg, count);
    }

    private void updateShopRating(UUID shopId) {
        BigDecimal avg = reviews.avgRatingByShop(shopId);
        int count = reviews.countByShopId(shopId);
        Shop shop = shopRepository.findById(shopId).orElse(null);
        if (shop != null) shop.updateRating(avg, count);
    }
}
