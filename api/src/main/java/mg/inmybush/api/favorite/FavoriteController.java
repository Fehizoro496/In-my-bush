package mg.inmybush.api.favorite;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.UUID;
import mg.inmybush.api.auth.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.favorite.dto.FavoriteResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me/favorites")
@Tag(name = "Me")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @GetMapping
    @Operation(summary = "Mes produits favoris")
    public PageResponse<FavoriteResponse> list(@RequestParam(defaultValue = "0") int page,
                                                @RequestParam(defaultValue = "20") int size) {
        return favoriteService.list(CurrentUser.id(), page, size);
    }

    @PutMapping("/{productId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Ajouter un favori")
    public void add(@PathVariable UUID productId) {
        favoriteService.add(CurrentUser.id(), productId);
    }

    @DeleteMapping("/{productId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Retirer un favori")
    public void remove(@PathVariable UUID productId) {
        favoriteService.remove(CurrentUser.id(), productId);
    }
}
