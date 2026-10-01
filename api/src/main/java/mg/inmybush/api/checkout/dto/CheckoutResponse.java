package mg.inmybush.api.checkout.dto;

import java.util.List;
import java.util.UUID;

public record CheckoutResponse(UUID checkoutId, List<UUID> orderIds, long total) {
}
