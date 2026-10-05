package mg.inmybush.api.auth.service;

/** SMS gateway abstraction (Telma/Orange/Airtel aggregator to plug in later). */
public interface SmsSender {

    void send(String phoneE164, String message);
}
