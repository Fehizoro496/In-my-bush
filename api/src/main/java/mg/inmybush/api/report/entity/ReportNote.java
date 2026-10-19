package mg.inmybush.api.report.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

/** Internal note of the moderation team on a report. */
@Entity
@Table(name = "report_notes")
public class ReportNote extends BaseEntity {

    @Column(name = "report_id", nullable = false)
    private UUID reportId;

    @Column(name = "author_id", nullable = false)
    private UUID authorId;

    @Column(name = "body", nullable = false, length = 1000)
    private String body;

    protected ReportNote() {
    }

    public ReportNote(UUID reportId, UUID authorId, String body) {
        this.reportId = reportId;
        this.authorId = authorId;
        this.body = body;
    }

    public UUID getReportId() { return reportId; }

    public UUID getAuthorId() { return authorId; }

    public String getBody() { return body; }
}
