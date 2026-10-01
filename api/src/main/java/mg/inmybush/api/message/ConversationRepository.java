package mg.inmybush.api.message;

import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ConversationRepository extends JpaRepository<Conversation, UUID> {

    @Query("select c from Conversation c where c.buyerId = :userId or c.shopId in "
        + "(select s.id from Shop s where s.owner.id = :userId)")
    Page<Conversation> findByParticipant(@Param("userId") UUID userId, Pageable pageable);
}
