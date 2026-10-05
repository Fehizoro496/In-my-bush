package mg.inmybush.api.notification.dto;

import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.notification.entity.Notification;
import mg.inmybush.api.notification.entity.NotificationContext;

public record NotificationResponse(
    UUID id,
    NotificationContext context,
    String type,
    String title,
    String body,
    String link,
    Instant readAt,
    Instant createdAt) {

    public static NotificationResponse from(Notification n) {
        return new NotificationResponse(n.getId(), n.getContext(), n.getType(), n.getTitle(),
            n.getBody(), n.getLink(), n.getReadAt(), n.getCreatedAt());
    }
}
