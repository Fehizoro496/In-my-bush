package mg.inmybush.api.report.repository;

import java.util.List;
import java.util.UUID;
import mg.inmybush.api.report.entity.ReportNote;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportNoteRepository extends JpaRepository<ReportNote, UUID> {

    List<ReportNote> findByReportIdOrderByCreatedAtAsc(UUID reportId);
}
