package mg.inmybush.api.settings;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;
import mg.inmybush.api.common.BadRequestException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Typed access to {@code platform_settings}. */
@Service
public class SettingsService {

    private final PlatformSettingRepository repository;

    public SettingsService(PlatformSettingRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public PricingSettings pricing() {
        return new PricingSettings(
            new BigDecimal(get(SettingKey.COMMISSION_RATE)),
            Long.parseLong(get(SettingKey.DELIVERY_FEE)),
            Long.parseLong(get(SettingKey.FREE_DELIVERY_THRESHOLD)));
    }

    @Transactional(readOnly = true)
    public int sellerAcceptHours() {
        return Integer.parseInt(get(SettingKey.SELLER_ACCEPT_HOURS));
    }

    @Transactional(readOnly = true)
    public int autoReleaseDays() {
        return Integer.parseInt(get(SettingKey.AUTO_RELEASE_DAYS));
    }

    @Transactional(readOnly = true)
    public Map<String, String> all() {
        Map<String, String> result = new LinkedHashMap<>();
        for (SettingKey key : SettingKey.values()) {
            result.put(key.key(), get(key));
        }
        return result;
    }

    @Transactional
    public Map<String, String> update(Map<String, String> changes) {
        changes.forEach((rawKey, value) -> {
            SettingKey key = SettingKey.fromKey(rawKey);
            if (key == null) {
                throw new BadRequestException("UNKNOWN_SETTING", "Paramètre inconnu : " + rawKey);
            }
            String error = value == null ? "Valeur manquante." : key.validate(value.trim());
            if (error != null) {
                throw new BadRequestException("INVALID_SETTING", rawKey + " : " + error);
            }
            repository.findById(key.key()).ifPresentOrElse(
                s -> s.setValue(value.trim()),
                () -> repository.save(new PlatformSetting(key.key(), value.trim())));
        });
        return all();
    }

    private String get(SettingKey key) {
        return repository.findById(key.key()).map(PlatformSetting::getValue).orElse(key.defaultValue());
    }
}
