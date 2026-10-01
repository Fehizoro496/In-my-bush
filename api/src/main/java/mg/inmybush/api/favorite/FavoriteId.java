package mg.inmybush.api.favorite;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

public class FavoriteId implements Serializable {

    private UUID userId;
    private UUID productId;

    public FavoriteId() {
    }

    public FavoriteId(UUID userId, UUID productId) {
        this.userId = userId;
        this.productId = productId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        FavoriteId that = (FavoriteId) o;
        return Objects.equals(userId, that.userId) && Objects.equals(productId, that.productId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, productId);
    }
}
