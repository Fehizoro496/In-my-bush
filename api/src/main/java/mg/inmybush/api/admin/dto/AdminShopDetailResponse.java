package mg.inmybush.api.admin.dto;

import java.util.List;

/** Backoffice sheet of a shop: its orders and reports counted, and the decisions taken on it, newest first. */
public record AdminShopDetailResponse(
    AdminShopResponse shop,
    long orderCount,
    long reportCount,
    List<AuditEventResponse> history) {
}
