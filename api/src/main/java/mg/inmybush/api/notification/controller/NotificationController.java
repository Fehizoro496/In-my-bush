package mg.inmybush.api.notification.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.UUID;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.notification.dto.NotificationResponse;
import mg.inmybush.api.notification.dto.UnreadCountResponse;
import mg.inmybush.api.notification.service.NotificationService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications")
@Tag(name = "Notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    @Operation(summary = "Mes notifications")
    public PageResponse<NotificationResponse> list(@RequestParam(defaultValue = "0") int page,
                                                    @RequestParam(defaultValue = "20") int size) {
        return notificationService.list(CurrentUser.id(), page, size);
    }

    @GetMapping("/unread-count")
    @Operation(summary = "Nombre de notifications non lues")
    public UnreadCountResponse unreadCount() {
        return new UnreadCountResponse(notificationService.unreadCount(CurrentUser.id()));
    }

    @PostMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Marquer une notification comme lue")
    public void markRead(@PathVariable UUID id) {
        notificationService.markRead(CurrentUser.id(), id);
    }

    @PostMapping("/read-all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Tout marquer comme lu")
    public void markAllRead() {
        notificationService.markAllRead(CurrentUser.id());
    }
}
