package mg.inmybush.api.admin.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import mg.inmybush.api.report.entity.ReportStatus;

public record ResolveReportRequest(
    @NotNull ReportStatus status,
    @Size(max = 500) String note) {
}
