package mg.inmybush.api.config;

import java.util.Arrays;
import org.springframework.boot.autoconfigure.flyway.FlywayConfigurationCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

/** Checked before migrations, so a conflicting dev profile cannot seed production. */
@Configuration
public class ProductionGuard {
    @Bean
    FlywayConfigurationCustomizer productionMigrationGuard(Environment environment) {
        return configuration -> {
            if (Arrays.asList(environment.getActiveProfiles()).contains("prod")) {
                if (Arrays.asList(environment.getActiveProfiles()).contains("dev") ||
                    Arrays.stream(configuration.getLocations()).anyMatch(l -> l.getDescriptor().contains("db/dev"))) {
                    throw new IllegalStateException("Les données de démonstration sont interdites en production.");
                }
            }
        };
    }
}
