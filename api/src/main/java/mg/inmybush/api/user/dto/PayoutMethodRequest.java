package mg.inmybush.api.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import mg.inmybush.api.payment.entity.PaymentMethod;

public record PayoutMethodRequest(@NotNull PaymentMethod method, @NotBlank String phone, Boolean isDefault) {
}
