package mg.inmybush.api.report.service;

import java.util.UUID;
import mg.inmybush.api.report.dto.CreateReportRequest;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.report.entity.Report;
import mg.inmybush.api.report.repository.ReportRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Reports sent by users; the backoffice handles them in AdminReportService. */
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
}
