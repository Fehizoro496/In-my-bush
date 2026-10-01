package mg.inmybush.api.common;

import org.springframework.http.HttpStatus;

/**
 * Base class for business errors rendered as RFC 7807 problems. {@code code} is a stable machine-readable
 * identifier (English), the message is the user-facing detail (French, shown by the clients).
 */
public class ApiException extends RuntimeException {

    private final HttpStatus status;
    private final String code;

    public ApiException(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public HttpStatus getStatus() { return status; }

    public String getCode() { return code; }
}
