package mg.inmybush.api.report.service;

import java.util.UUID;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.report.dto.CreateReportRequest;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.report.entity.Report;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.repository.ReportRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReportService {

    private final ReportRepository reports;

    public ReportService(ReportRepository reports) {
        this.reports = reports;
    }

    @Transactional
    public ReportResponse create(UUID userId, CreateReportRequest req) {
        Report report = new Report(userId, req.targetType(), req.targetId(), req.reason(), req.details());
        reports.save(report);
        return ReportResponse.from(report);
    }

    @Transactional(readOnly = true)
    public PageResponse<ReportResponse> list(ReportStatus status, int page, int size) {
        if (status != null) {
            return PageResponse.of(reports.findByStatus(status, Pages.newestFirst(page, size)), ReportResponse::from);
        }
        return PageResponse.of(reports.findAll(Pages.newestFirst(page, size)), ReportResponse::from);
    }

    @Transactional
    public ReportResponse resolve(UUID adminId, UUID reportId, ReportStatus newStatus, String note) {
        Report report = reports.findById(reportId)
            .orElseThrow(() -> NotFoundException.of("Signalement", reportId));
        report.resolve(adminId, newStatus, note);
        return ReportResponse.from(report);
    }
}
