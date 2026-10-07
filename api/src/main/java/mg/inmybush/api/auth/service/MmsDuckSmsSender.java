package mg.inmybush.api.auth.service;

import java.net.http.HttpClient;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Map;
import mg.inmybush.api.common.ApiException;
import mg.inmybush.api.config.AppProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

/**
 * Sends SMS through the MMSDuck API ({@code POST /api/v1/sms/send}). MMSDuck prepends the company name of the
 * account to every message, so the text itself does not need to carry it.
 *
 * @see <a href="https://mmsduck.com/documentation">MMSDuck — documentation</a>
 */
public class MmsDuckSmsSender implements SmsSender {

    private static final Logger log = LoggerFactory.getLogger(MmsDuckSmsSender.class);
    private static final String SEND_PATH = "/api/v1/sms/send";

    private final RestClient client;
    private final String baseUrl;

    public MmsDuckSmsSender(AppProperties.MmsDuck props, RestClient.Builder builder) {
        // java.net.http client: unlike HttpURLConnection, it keeps the body of error responses (logged below).
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(
            HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build());
        requestFactory.setReadTimeout(Duration.ofSeconds(10));
        this.client = builder
            .baseUrl(props.baseUrl())
            .requestFactory(requestFactory)
            .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + props.apiKey())
            .build();
        this.baseUrl = props.baseUrl();
    }

    @Override
    public void send(String phoneE164, String message) {
        Map<String, String> body = Map.of("to", phoneE164, "message", message);
        log.info("MMSDuck request: POST {}{} to={}", baseUrl, SEND_PATH, phoneE164);
        // The text holds the one-time code: only shown at DEBUG level (off in production).
        log.debug("MMSDuck request body: {}", body);
        try {
            ResponseEntity<String> response = client.post()
                .uri(SEND_PATH)
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .retrieve()
                .toEntity(String.class);
            log.info("MMSDuck response: {} {}", response.getStatusCode().value(), response.getBody());
        } catch (RestClientResponseException e) {
            // MMSDuck answered with an error: { success: false, error: { code, message } }
            log.error("MMSDuck response: {} {}", e.getStatusCode().value(), e.getResponseBodyAsString(StandardCharsets.UTF_8));
            throw notSent();
        } catch (RestClientException e) {
            log.error("MMSDuck unreachable: {}", e.getMessage());
            throw notSent();
        }
    }

    private static ApiException notSent() {
        return new ApiException(HttpStatus.BAD_GATEWAY, "SMS_NOT_SENT",
            "L'envoi du SMS a échoué. Veuillez réessayer dans un instant.");
    }
}
