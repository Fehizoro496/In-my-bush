package mg.inmybush.api.report;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import mg.inmybush.api.auth.CurrentUser;
import mg.inmybush.api.report.dto.CreateReportRequest;
import mg.inmybush.api.report.dto.ReportResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/reports")
@Tag(name = "Signalement")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Signaler un contenu")
    public ReportResponse create(@Valid @RequestBody CreateReportRequest request) {
        return reportService.create(CurrentUser.id(), request);
    }
}
