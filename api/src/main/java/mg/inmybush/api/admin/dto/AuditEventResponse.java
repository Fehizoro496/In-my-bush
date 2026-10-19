package mg.inmybush.api.admin.dto;

import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.admin.entity.AuditEvent;

/** One line of the administration journal; {@code actorName} is null if the account no longer exists. */
public record AuditEventResponse(
    UUID id,
    UUID actorId,
    String actorName,
    String action,
    String targetType,
    UUID targetId,
    String reason,
    Instant createdAt) {

    public static AuditEventResponse from(AuditEvent event, String actorName) {
        return new AuditEventResponse(event.getId(), event.getActorId(), actorName, event.getAction(),
            event.getTargetType(), event.getTargetId(), event.getReason(), event.getCreatedAt());
    }
}
