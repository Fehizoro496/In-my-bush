package mg.inmybush.api.notification.service;

import java.util.UUID;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.notification.dto.NotificationResponse;
import mg.inmybush.api.notification.entity.Notification;
import mg.inmybush.api.notification.entity.NotificationContext;
import mg.inmybush.api.notification.repository.NotificationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationService {

    private final NotificationRepository notifications;

    public NotificationService(NotificationRepository notifications) {
        this.notifications = notifications;
    }

    @Transactional(readOnly = true)
    public PageResponse<NotificationResponse> list(UUID userId, int page, int size) {
        return PageResponse.of(notifications.findByUserId(userId, Pages.newestFirst(page, size)),
            NotificationResponse::from);
    }

    @Transactional(readOnly = true)
    public long unreadCount(UUID userId) {
        return notifications.countUnread(userId);
    }

    @Transactional
    public void markRead(UUID userId, UUID notificationId) {
        Notification n = notifications.findById(notificationId)
            .orElseThrow(() -> NotFoundException.of("Notification", notificationId));
        if (!n.getUserId().equals(userId)) {
            throw NotFoundException.of("Notification", notificationId);
        }
        n.markRead();
    }

    @Transactional
    public void markAllRead(UUID userId) {
        notifications.markAllRead(userId);
    }

    /** Creates a notification (used internally by other services). */
    @Transactional
    public Notification create(UUID userId, NotificationContext context, String type, String title, String body, String link) {
        return notifications.save(new Notification(userId, context, type, title, body, link));
    }

    /** Convenience alias used by domain services (e.g. ProductModerationService). */
    @Transactional
    public void notify(UUID userId, NotificationContext context, String type, String title, String body, String link) {
        create(userId, context, type, title, body, link);
    }
}
