package mg.inmybush.api.admin.entity;

import jakarta.persistence.*;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "admin_audit_events")
public class AuditEvent extends BaseEntity {
    @Column(name = "actor_id", nullable = false) private UUID actorId;
    @Column(nullable = false, length = 80) private String action;
    @Column(name = "target_type", nullable = false, length = 40) private String targetType;
    @Column(name = "target_id") private UUID targetId;
    @Column(length = 1000) private String reason;

    protected AuditEvent() {}
    public AuditEvent(UUID actorId, String action, String targetType, UUID targetId, String reason) {
        this.actorId = actorId;
        this.action = action;
        this.targetType = targetType;
        this.targetId = targetId;
        this.reason = reason;
    }
    public UUID getActorId() { return actorId; }
    public String getAction() { return action; }
    public String getTargetType() { return targetType; }
    public UUID getTargetId() { return targetId; }
    public String getReason() { return reason; }
}
