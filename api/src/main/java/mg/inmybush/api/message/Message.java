package mg.inmybush.api.message;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "messages")
public class Message extends BaseEntity {

    @Column(name = "conversation_id", nullable = false)
    private UUID conversationId;

    @Column(name = "sender_id", nullable = false)
    private UUID senderId;

    @Column(name = "body", nullable = false, columnDefinition = "text")
    private String body;

    @Column(name = "read_at")
    private Instant readAt;

    protected Message() {
    }

    public Message(UUID conversationId, UUID senderId, String body) {
        this.conversationId = conversationId;
        this.senderId = senderId;
        this.body = body;
    }

    public void markRead() {
        if (readAt == null) readAt = Instant.now();
    }

    public UUID getConversationId() { return conversationId; }

    public UUID getSenderId() { return senderId; }

    public String getBody() { return body; }

    public Instant getReadAt() { return readAt; }
}
