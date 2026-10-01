package mg.inmybush.api.common;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Ariary helpers: amounts are whole numbers, percentages are rounded half-up to the Ariary. */
public final class Money {

    private Money() {
    }

    public static long percentOf(long amount, BigDecimal rate) {
        return BigDecimal.valueOf(amount).multiply(rate).setScale(0, RoundingMode.HALF_UP).longValueExact();
    }
}
