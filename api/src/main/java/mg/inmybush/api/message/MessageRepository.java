package mg.inmybush.api.message;

import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MessageRepository extends JpaRepository<Message, UUID> {

    Page<Message> findByConversationId(UUID conversationId, Pageable pageable);

    @Modifying
    @Query("update Message m set m.readAt = current_timestamp where m.conversationId = :convId "
        + "and m.senderId <> :userId and m.readAt is null")
    void markAllRead(@Param("convId") UUID conversationId, @Param("userId") UUID userId);
}
