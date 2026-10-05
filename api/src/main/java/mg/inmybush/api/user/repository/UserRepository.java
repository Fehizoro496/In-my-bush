package mg.inmybush.api.user.repository;

import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.user.entity.Role;
import mg.inmybush.api.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface UserRepository extends JpaRepository<User, UUID>, JpaSpecificationExecutor<User> {

    Optional<User> findByPhone(String phone);

    Optional<User> findByEmailIgnoreCase(String email);

    boolean existsByPhone(String phone);

    boolean existsByEmailIgnoreCase(String email);

    long countByRolesContaining(Role role);
}
