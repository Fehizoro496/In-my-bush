package mg.inmybush.api.auth.service;

/** SMS gateway abstraction (see {@code SmsConfig} for the implementation in use). */
public interface SmsSender {

    void send(String phoneE164, String message);
}
