package mg.inmybush.api.notification;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "notifications")
public class Notification extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "context", nullable = false, length = 20)
    private NotificationContext context;

    @Column(name = "type", nullable = false, length = 40)
    private String type;

    @Column(name = "title", nullable = false, length = 160)
    private String title;

    @Column(name = "body", length = 500)
    private String body;

    @Column(name = "link", length = 300)
    private String link;

    @Column(name = "read_at")
    private Instant readAt;

    protected Notification() {
    }

    public Notification(UUID userId, NotificationContext context, String type, String title, String body, String link) {
        this.userId = userId;
        this.context = context;
        this.type = type;
        this.title = title;
        this.body = body;
        this.link = link;
    }

    public void markRead() {
        if (readAt == null) readAt = Instant.now();
    }

    public UUID getUserId() { return userId; }

    public NotificationContext getContext() { return context; }

    public String getType() { return type; }

    public String getTitle() { return title; }

    public String getBody() { return body; }

    public String getLink() { return link; }

    public Instant getReadAt() { return readAt; }
}
