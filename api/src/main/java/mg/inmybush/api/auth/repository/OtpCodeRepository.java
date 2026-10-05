package mg.inmybush.api.auth.repository;

import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.auth.entity.OtpCode;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OtpCodeRepository extends JpaRepository<OtpCode, UUID> {

    Optional<OtpCode> findFirstByPhoneAndConsumedAtIsNullOrderByCreatedAtDesc(String phone);

    Optional<OtpCode> findFirstByPhoneOrderByCreatedAtDesc(String phone);
}
