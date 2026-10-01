package mg.inmybush.api.report.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.UUID;
import mg.inmybush.api.report.TargetType;

public record CreateReportRequest(
    @NotNull TargetType targetType,
    @NotNull UUID targetId,
    @NotBlank @Size(max = 80) String reason,
    @Size(max = 2000) String details) {
}
