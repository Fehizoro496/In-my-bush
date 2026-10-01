package mg.inmybush.api.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/** Stub implementation: logs the SMS instead of sending it. */
@Component
public class LoggingSmsSender implements SmsSender {

    private static final Logger log = LoggerFactory.getLogger(LoggingSmsSender.class);

    @Override
    public void send(String phoneE164, String message) {
        log.info("[SMS stub] to {}: {}", phoneE164, message);
    }
}
