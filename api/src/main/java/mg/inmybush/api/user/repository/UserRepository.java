package mg.inmybush.api.user.repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.user.entity.Role;
import mg.inmybush.api.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

public interface UserRepository extends JpaRepository<User, UUID>, JpaSpecificationExecutor<User> {

    Optional<User> findByPhone(String phone);

    Optional<User> findByEmailIgnoreCase(String email);

    boolean existsByPhone(String phone);

    boolean existsByEmailIgnoreCase(String email);

    long countByRolesContaining(Role role);

    /** Active administrators, locked so that two of them cannot withdraw each other's access at the same time. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from User u join u.roles r where r = mg.inmybush.api.user.entity.Role.ADMIN "
        + "and u.status = mg.inmybush.api.user.entity.UserStatus.ACTIVE order by u.id")
    List<User> lockActiveAdmins();
}
