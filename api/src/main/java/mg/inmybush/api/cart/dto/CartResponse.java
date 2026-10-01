package mg.inmybush.api.cart.dto;

import java.util.List;

public record CartResponse(List<CartItemResponse> items, long total, int itemCount) {
}
