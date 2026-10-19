package mg.inmybush.api.admin.dto;

import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.report.entity.ReportNote;

/** Internal note of the moderation team; {@code authorName} is null if the account no longer exists. */
public record ReportNoteResponse(UUID id, UUID authorId, String authorName, String body, Instant createdAt) {

    public static ReportNoteResponse from(ReportNote n, String authorName) {
        return new ReportNoteResponse(n.getId(), n.getAuthorId(), authorName, n.getBody(), n.getCreatedAt());
    }
}
