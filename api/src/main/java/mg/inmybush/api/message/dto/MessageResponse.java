package mg.inmybush.api.message.dto;

import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.message.entity.Message;

public record MessageResponse(
    UUID id,
    UUID senderId,
    String senderName,
    String body,
    Instant readAt,
    Instant createdAt) {

    public static MessageResponse from(Message m, String senderName) {
        return new MessageResponse(m.getId(), m.getSenderId(), senderName, m.getBody(), m.getReadAt(), m.getCreatedAt());
    }
}
