package mg.inmybush.api.checkout.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.UUID;
import mg.inmybush.api.order.entity.DeliveryMode;
import mg.inmybush.api.payment.entity.PaymentMethod;

public record CheckoutRequest(
    @NotNull DeliveryMode deliveryMode,
    UUID addressId,
    @Size(max = 80) String deliverySlot,
    @Size(max = 500) String note,
    @NotNull PaymentMethod paymentMethod,
    @Size(max = 20) String paymentPhone) {
}
