package mg.inmybush.api.admin.dto;

import java.util.UUID;

/**
 * What a report points at, as the moderator needs to judge it: a title, the reported text, the current status
 * of the content, and the account and shop behind it. {@code found} is false once the content is deleted.
 */
public record ReportTargetResponse(
    boolean found,
    String title,
    String excerpt,
    String status,
    String productSlug,
    UUID userId,
    String userName,
    UUID shopId,
    String shopName) {

    public static ReportTargetResponse missing() {
        return new ReportTargetResponse(false, null, null, null, null, null, null, null, null);
    }
}
