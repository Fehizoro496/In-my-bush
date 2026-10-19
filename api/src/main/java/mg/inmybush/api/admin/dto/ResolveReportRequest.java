package mg.inmybush.api.admin.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import mg.inmybush.api.report.entity.ReportStatus;

/** IN_REVIEW takes the report in charge; RESOLVED and DISMISSED close it and require the reason of the decision. */
public record ResolveReportRequest(
    @NotNull ReportStatus status,
    @Size(max = 500) String note) {
}
