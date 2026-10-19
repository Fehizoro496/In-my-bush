package mg.inmybush.api.admin.service;

import java.util.Collection;
import java.util.List;
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
        Map<UUID, String> names = names(found.map(AuditEvent::getActorId).toSet());
        return PageResponse.of(found, e -> AuditEventResponse.from(e, names.get(e.getActorId())));
    }

    /** The latest decisions taken on one target, newest first. */
    @Transactional(readOnly = true)
    public List<AuditEventResponse> history(String type, UUID target) {
        List<AuditEvent> found = events.findTop50ByTargetTypeAndTargetIdOrderByCreatedAtDesc(type, target);
        Map<UUID, String> names = names(found.stream().map(AuditEvent::getActorId).toList());
        return found.stream().map(e -> AuditEventResponse.from(e, names.get(e.getActorId()))).toList();
    }

    /** Full names of the given accounts, by id. */
    @Transactional(readOnly = true)
    public Map<UUID, String> names(Collection<UUID> ids) {
        return users.findAllById(ids).stream().collect(Collectors.toMap(User::getId, User::getFullName));
    }
}
