package mg.inmybush.api.user;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface UserRepository extends JpaRepository<User, UUID>, JpaSpecificationExecutor<User> {

    Optional<User> findByPhone(String phone);

    Optional<User> findByEmailIgnoreCase(String email);

    boolean existsByPhone(String phone);

    boolean existsByEmailIgnoreCase(String email);

    long countByRolesContaining(Role role);
}
