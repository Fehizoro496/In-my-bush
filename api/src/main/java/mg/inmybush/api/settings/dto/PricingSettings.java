package mg.inmybush.api.settings.dto;

import java.math.BigDecimal;

/**
 * Pricing parameters applied at checkout.
 *
 * @param commissionRate        share of the order subtotal kept by In my bush (0.10 = 10 %)
 * @param deliveryFee           flat home-delivery fee per order (Ariary)
 * @param freeDeliveryThreshold subtotal from which home delivery is free, 0 = never
 */
public record PricingSettings(BigDecimal commissionRate, long deliveryFee, long freeDeliveryThreshold) {
}
