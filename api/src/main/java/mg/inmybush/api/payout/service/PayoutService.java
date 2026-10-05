package mg.inmybush.api.payout.service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.order.entity.Order;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.order.entity.OrderStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import mg.inmybush.api.payout.entity.Payout;
import mg.inmybush.api.payout.repository.PayoutRepository;

@Service
public class PayoutService {

    private static final Logger log = LoggerFactory.getLogger(PayoutService.class);

    private final PayoutRepository payouts;
    private final OrderRepository orders;

    public PayoutService(PayoutRepository payouts, OrderRepository orders) {
        this.payouts = payouts;
        this.orders = orders;
    }

    /** Runs daily; creates SCHEDULED payouts for each shop with delivered, unpaid orders. */
    @Scheduled(cron = "0 0 2 * * *")
    @Transactional
    public void generatePayouts() {
        log.info("Generating payouts...");
        LocalDate today = LocalDate.now();
        LocalDate periodStart = today.minusDays(7);

        List<UUID> shopIds = orders.findShopIdsWithUnpaidOrders(OrderStatus.DELIVERED);
        for (UUID shopId : shopIds) {
            List<Order> delivered = orders.findByShopIdAndStatusAndPayoutIdIsNull(shopId, OrderStatus.DELIVERED);
            if (delivered.isEmpty()) continue;
            long total = delivered.stream().mapToLong(Order::getSellerNet).sum();
            if (total <= 0) continue;
            Payout payout = new Payout(shopId, total, periodStart, today);
            payouts.save(payout);
            for (Order order : delivered) {
                order.setPayoutId(payout.getId());
            }
            log.info("Payout created for shop {} — {} Ar", shopId, total);
        }
    }
}
