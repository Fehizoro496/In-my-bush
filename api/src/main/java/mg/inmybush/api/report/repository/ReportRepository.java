package mg.inmybush.api.report.repository;

import java.util.UUID;
import mg.inmybush.api.report.entity.Report;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.entity.TargetType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface ReportRepository extends JpaRepository<Report, UUID>, JpaSpecificationExecutor<Report> {

    long countByStatus(ReportStatus status);

    long countByTargetTypeAndTargetId(TargetType targetType, UUID targetId);
}
