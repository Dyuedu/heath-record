package backend.exception;

import org.springframework.http.HttpStatus;

public class AccessDeniedException extends BaseException {
    private static final String ERROR_CODE = "ACCESS_DENIED";

    public AccessDeniedException(String message) {
        super(ERROR_CODE, message, HttpStatus.FORBIDDEN);
    }

    public AccessDeniedException(String message, Throwable cause) {
        super(ERROR_CODE, message, HttpStatus.FORBIDDEN);
        initCause(cause);
    }
}
