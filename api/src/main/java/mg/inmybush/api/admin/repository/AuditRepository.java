package mg.inmybush.api.admin.repository;

import java.util.List;
import java.util.UUID;
import mg.inmybush.api.admin.entity.AuditEvent;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditRepository extends JpaRepository<AuditEvent, UUID> {

    List<AuditEvent> findTop50ByTargetTypeAndTargetIdOrderByCreatedAtDesc(String targetType, UUID targetId);
}
