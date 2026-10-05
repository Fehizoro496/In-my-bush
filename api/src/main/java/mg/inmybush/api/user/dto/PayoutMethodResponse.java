package mg.inmybush.api.user.dto;

import java.util.UUID;
import mg.inmybush.api.payment.entity.PaymentMethod;
import mg.inmybush.api.user.entity.PayoutMethod;

public record PayoutMethodResponse(UUID id, PaymentMethod method, String phoneMasked, boolean isDefault) {

    public static PayoutMethodResponse from(PayoutMethod p) {
        return new PayoutMethodResponse(p.getId(), p.getMethod(), p.getPhoneMasked(), p.isDefault());
    }
}
