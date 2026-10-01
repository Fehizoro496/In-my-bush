package mg.inmybush.api.report.dto;

import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.report.Report;
import mg.inmybush.api.report.ReportStatus;
import mg.inmybush.api.report.TargetType;

public record ReportResponse(
    UUID id,
    UUID reporterId,
    TargetType targetType,
    UUID targetId,
    String reason,
    String details,
    ReportStatus status,
    String resolutionNote,
    UUID resolvedBy,
    Instant resolvedAt,
    Instant createdAt) {

    public static ReportResponse from(Report r) {
        return new ReportResponse(r.getId(), r.getReporterId(), r.getTargetType(), r.getTargetId(),
            r.getReason(), r.getDetails(), r.getStatus(), r.getResolutionNote(), r.getResolvedBy(),
            r.getResolvedAt(), r.getCreatedAt());
    }
}
