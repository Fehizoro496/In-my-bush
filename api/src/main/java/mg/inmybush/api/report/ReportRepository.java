package mg.inmybush.api.report;

import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportRepository extends JpaRepository<Report, UUID> {

    Page<Report> findByStatus(ReportStatus status, Pageable pageable);

    long countByStatus(ReportStatus status);
}
