package mg.inmybush.api.notification.entity;

/** Notification type constants used across the application. */
public final class NotificationType {

    private NotificationType() {
    }

    public static final String ORDER_PLACED = "ORDER_PLACED";
    public static final String ORDER_ACCEPTED = "ORDER_ACCEPTED";
    public static final String ORDER_REFUSED = "ORDER_REFUSED";
    public static final String ORDER_PREPARED = "ORDER_PREPARED";
    public static final String ORDER_SHIPPED = "ORDER_SHIPPED";
    public static final String ORDER_DELIVERED = "ORDER_DELIVERED";
    public static final String ORDER_CANCELLED = "ORDER_CANCELLED";
    public static final String PRODUCT_APPROVED = "PRODUCT_APPROVED";
    public static final String PRODUCT_REJECTED = "PRODUCT_REJECTED";
    public static final String PRODUCT_WITHDRAWN = "PRODUCT_WITHDRAWN";
    public static final String SHOP_SUSPENDED = "SHOP_SUSPENDED";
    public static final String SHOP_REACTIVATED = "SHOP_REACTIVATED";
    public static final String ACCOUNT_SUSPENDED = "ACCOUNT_SUSPENDED";
    public static final String ACCOUNT_BANNED = "ACCOUNT_BANNED";
    public static final String ACCOUNT_REACTIVATED = "ACCOUNT_REACTIVATED";
    public static final String REPORT_HANDLED = "REPORT_HANDLED";
    public static final String NEW_REVIEW = "NEW_REVIEW";
    public static final String NEW_MESSAGE = "NEW_MESSAGE";
    public static final String PAYOUT_SENT = "PAYOUT_SENT";
}
