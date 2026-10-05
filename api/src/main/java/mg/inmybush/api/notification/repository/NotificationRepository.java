package mg.inmybush.api.notification.repository;

import java.util.UUID;
import mg.inmybush.api.notification.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    Page<Notification> findByUserId(UUID userId, Pageable pageable);

    @Query("select count(n) from Notification n where n.userId = :userId and n.readAt is null")
    long countUnread(@Param("userId") UUID userId);

    @Modifying
    @Query("update Notification n set n.readAt = current_timestamp where n.userId = :userId and n.readAt is null")
    void markAllRead(@Param("userId") UUID userId);
}
