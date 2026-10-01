package mg.inmybush.api.payment;

import java.util.UUID;
import mg.inmybush.api.common.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PaymentService {

    private final PaymentRepository payments;

    public PaymentService(PaymentRepository payments) {
        this.payments = payments;
    }

    @Transactional
    public Payment create(UUID checkoutId, PaymentMethod method, String phone, long amount) {
        return payments.save(new Payment(checkoutId, method, phone, amount));
    }

    @Transactional(readOnly = true)
    public Payment findByCheckout(UUID checkoutId) {
        return payments.findByCheckoutId(checkoutId)
            .orElseThrow(() -> NotFoundException.of("Paiement", checkoutId));
    }
}
