package mg.inmybush.api.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ReportNoteRequest(@NotBlank @Size(max = 1000) String body) {
}
