package mg.inmybush.api.admin.dto;

import java.util.List;
import mg.inmybush.api.report.dto.ReportResponse;

/**
 * Backoffice sheet of a report: the reported content, how many reports it received in all, the internal notes
 * in the order they were written and the decisions taken, newest first.
 */
public record AdminReportDetailResponse(
    ReportResponse report,
    String reporterName,
    String resolvedByName,
    ReportTargetResponse target,
    long targetReportCount,
    List<ReportNoteResponse> notes,
    List<AuditEventResponse> history) {
}
