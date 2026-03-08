package backend.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

/**
 * BaseException serves as a foundation for custom exceptions used across the 
 * application. It provides a mechanism to associate error codes and HTTP status 
 * with the corresponding exception.
 */
@Getter
public abstract class BaseException extends RuntimeException {
    private final String errorCode;
    private final HttpStatus status;

    public BaseException(String errorCode, String message, HttpStatus status) {
        super(message);
        this.errorCode = errorCode;
        this.status = status;
    }
}
