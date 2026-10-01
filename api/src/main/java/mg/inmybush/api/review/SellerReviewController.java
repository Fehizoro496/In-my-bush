package mg.inmybush.api.review;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import mg.inmybush.api.auth.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.review.dto.ReplyRequest;
import mg.inmybush.api.review.dto.ReviewResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/seller/reviews")
@Tag(name = "Vendeur")
public class SellerReviewController {

    private final ReviewService reviewService;

    public SellerReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping
    @Operation(summary = "Avis sur les produits de ma boutique")
    public PageResponse<ReviewResponse> list(@RequestParam(defaultValue = "0") int page,
                                              @RequestParam(defaultValue = "20") int size) {
        return reviewService.shopReviews(CurrentUser.id(), page, size);
    }

    @PostMapping("/{id}/reply")
    @Operation(summary = "Répondre à un avis")
    public ReviewResponse reply(@PathVariable UUID id, @Valid @RequestBody ReplyRequest request) {
        return reviewService.reply(CurrentUser.id(), id, request.reply());
    }
}
