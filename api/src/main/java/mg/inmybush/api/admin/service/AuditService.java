package mg.inmybush.api.admin.service;

import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import mg.inmybush.api.admin.dto.AuditEventResponse;
import mg.inmybush.api.admin.entity.AuditEvent;
import mg.inmybush.api.admin.repository.AuditRepository;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.user.entity.User;
import mg.inmybush.api.user.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuditService {

    private final AuditRepository events;
    private final UserRepository users;

    public AuditService(AuditRepository events, UserRepository users) {
        this.events = events;
        this.users = users;
    }

    /** The event commits or rolls back together with the administrative mutation. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void record(String action, String type, UUID target, String reason) {
        events.save(new AuditEvent(CurrentUser.id(), action, type, target, reason));
    }

    @Transactional(readOnly = true)
    public PageResponse<AuditEventResponse> list(int page, int size) {
        Page<AuditEvent> found = events.findAll(Pages.newestFirst(page, size));
        Map<UUID, String> names = users.findAllById(found.map(AuditEvent::getActorId).toSet()).stream()
            .collect(Collectors.toMap(User::getId, u -> u.getFirstName() + " " + u.getLastName()));
        return PageResponse.of(found, e -> AuditEventResponse.from(e, names.get(e.getActorId())));
    }
}
