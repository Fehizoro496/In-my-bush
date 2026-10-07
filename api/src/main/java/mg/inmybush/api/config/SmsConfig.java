package mg.inmybush.api.config;

import mg.inmybush.api.auth.service.LoggingSmsSender;
import mg.inmybush.api.auth.service.MmsDuckSmsSender;
import mg.inmybush.api.auth.service.SmsSender;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

/** Picks the SMS gateway: MMSDuck when an API key is configured, otherwise a stub that logs the message. */
@Configuration
public class SmsConfig {

    private static final Logger log = LoggerFactory.getLogger(SmsConfig.class);

    @Bean
    public SmsSender smsSender(AppProperties props, RestClient.Builder restClientBuilder) {
        AppProperties.MmsDuck mmsDuck = props.sms().mmsduck();
        if (mmsDuck.apiKey() == null || mmsDuck.apiKey().isBlank()) {
            log.warn("SMS gateway: none. MMSDUCK_API_KEY is not set (api/.env or environment): SMS are only logged.");
            return new LoggingSmsSender();
        }
        String key = mmsDuck.apiKey().trim();
        log.info("SMS gateway: MMSDuck at {} (key {}..., {} characters)", mmsDuck.baseUrl(),
            key.substring(0, Math.min(13, key.length())), key.length());
        return new MmsDuckSmsSender(mmsDuck, restClientBuilder);
    }
}
