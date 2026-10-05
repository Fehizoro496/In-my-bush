package mg.inmybush.api.settings.repository;

import mg.inmybush.api.settings.entity.PlatformSetting;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlatformSettingRepository extends JpaRepository<PlatformSetting, String> {
}
