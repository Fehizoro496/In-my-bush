package mg.inmybush.api.auth.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** Stub implementation: logs the SMS instead of sending it (used when no gateway is configured). */
public class LoggingSmsSender implements SmsSender {

    private static final Logger log = LoggerFactory.getLogger(LoggingSmsSender.class);

    @Override
    public void send(String phoneE164, String message) {
        log.warn("[SMS stub — NOT SENT, no MMSDUCK_API_KEY] to {}: {}", phoneE164, message);
    }
}
