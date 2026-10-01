package mg.inmybush.api.user;

import java.util.List;
import java.util.UUID;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PhoneNumbers;
import mg.inmybush.api.payment.PaymentMethod;
import mg.inmybush.api.user.dto.PayoutMethodRequest;
import mg.inmybush.api.user.dto.PayoutMethodResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PayoutMethodService {

    private final PayoutMethodRepository methods;

    public PayoutMethodService(PayoutMethodRepository methods) {
        this.methods = methods;
    }

    @Transactional(readOnly = true)
    public List<PayoutMethodResponse> list(UUID userId) {
        return methods.findByUserIdOrderByIsDefaultDescCreatedAtAsc(userId).stream().map(PayoutMethodResponse::from).toList();
    }

    @Transactional
    public PayoutMethodResponse create(UUID userId, PayoutMethodRequest req) {
        if (req.method() == PaymentMethod.CASH_ON_DELIVERY) {
            throw new BadRequestException("INVALID_PAYOUT_METHOD", "Les versements se font uniquement par Mobile Money.");
        }
        List<PayoutMethod> existing = methods.findByUserIdOrderByIsDefaultDescCreatedAtAsc(userId);
        PayoutMethod pm = methods.save(new PayoutMethod(userId, req.method(), PhoneNumbers.normalize(req.phone())));
        if (existing.isEmpty() || Boolean.TRUE.equals(req.isDefault())) {
            existing.forEach(e -> e.setDefault(false));
            pm.setDefault(true);
        }
        return PayoutMethodResponse.from(pm);
    }

    @Transactional
    public void delete(UUID userId, UUID id) {
        PayoutMethod pm = methods.findByIdAndUserId(id, userId).orElseThrow(() -> NotFoundException.of("Moyen de versement", id));
        boolean wasDefault = pm.isDefault();
        methods.delete(pm);
        methods.flush();
        if (wasDefault) {
            methods.findFirstByUserIdOrderByIsDefaultDescCreatedAtAsc(userId).ifPresent(next -> next.setDefault(true));
        }
    }
}
