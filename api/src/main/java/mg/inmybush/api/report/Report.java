package mg.inmybush.api.report;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "reports")
public class Report extends BaseEntity {

    @Column(name = "reporter_id", nullable = false)
    private UUID reporterId;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", nullable = false, length = 20)
    private TargetType targetType;

    @Column(name = "target_id", nullable = false)
    private UUID targetId;

    @Column(name = "reason", nullable = false, length = 80)
    private String reason;

    @Column(name = "details", columnDefinition = "text")
    private String details;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ReportStatus status = ReportStatus.OPEN;

    @Column(name = "resolution_note", length = 500)
    private String resolutionNote;

    @Column(name = "resolved_by")
    private UUID resolvedBy;

    @Column(name = "resolved_at")
    private Instant resolvedAt;

    protected Report() {
    }

    public Report(UUID reporterId, TargetType targetType, UUID targetId, String reason, String details) {
        this.reporterId = reporterId;
        this.targetType = targetType;
        this.targetId = targetId;
        this.reason = reason;
        this.details = details;
    }

    public void resolve(UUID adminId, ReportStatus newStatus, String note) {
        this.status = newStatus;
        this.resolutionNote = note;
        this.resolvedBy = adminId;
        this.resolvedAt = Instant.now();
    }

    public UUID getReporterId() { return reporterId; }

    public TargetType getTargetType() { return targetType; }

    public UUID getTargetId() { return targetId; }

    public String getReason() { return reason; }

    public String getDetails() { return details; }

    public ReportStatus getStatus() { return status; }

    public String getResolutionNote() { return resolutionNote; }

    public UUID getResolvedBy() { return resolvedBy; }

    public Instant getResolvedAt() { return resolvedAt; }
}
