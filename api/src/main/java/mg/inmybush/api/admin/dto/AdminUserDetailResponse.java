package mg.inmybush.api.admin.dto;

import java.util.List;

/**
 * Backoffice sheet of an account: its shop if it sells, its activity, the reports against it and the
 * decisions taken on it, newest first.
 */
public record AdminUserDetailResponse(
    AdminUserResponse user,
    AdminShopRef shop,
    long orderCount,
    long reportCount,
    List<AuditEventResponse> history) {
}
