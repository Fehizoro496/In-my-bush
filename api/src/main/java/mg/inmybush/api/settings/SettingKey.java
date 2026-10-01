package mg.inmybush.api.settings;

import java.math.BigDecimal;

/** Known platform settings with their validation rule and default value. */
public enum SettingKey {
    COMMISSION_RATE("commission_rate", "0.10"),
    DELIVERY_FEE("delivery_fee", "3000"),
    FREE_DELIVERY_THRESHOLD("free_delivery_threshold", "0"),
    SELLER_ACCEPT_HOURS("seller_accept_hours", "24"),
    AUTO_RELEASE_DAYS("auto_release_days", "3");

    private final String key;
    private final String defaultValue;

    SettingKey(String key, String defaultValue) {
        this.key = key;
        this.defaultValue = defaultValue;
    }

    public String key() { return key; }

    public String defaultValue() { return defaultValue; }

    public static SettingKey fromKey(String key) {
        for (SettingKey k : values()) {
            if (k.key.equals(key)) {
                return k;
            }
        }
        return null;
    }

    /** Returns an error message, or null when the value is acceptable. */
    public String validate(String value) {
        try {
            if (this == COMMISSION_RATE) {
                BigDecimal rate = new BigDecimal(value);
                return rate.signum() < 0 || rate.compareTo(new BigDecimal("0.5")) > 0
                    ? "Le taux de commission doit être compris entre 0 et 0.5." : null;
            }
            long n = Long.parseLong(value);
            if (n < 0) {
                return "La valeur doit être positive.";
            }
            if ((this == SELLER_ACCEPT_HOURS || this == AUTO_RELEASE_DAYS) && n == 0) {
                return "La valeur doit être supérieure à 0.";
            }
            return null;
        } catch (NumberFormatException e) {
            return "Valeur numérique attendue.";
        }
    }
}
