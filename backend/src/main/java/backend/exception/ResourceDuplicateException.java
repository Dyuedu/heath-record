package backend.exception;

import org.springframework.http.HttpStatus;

public class ResourceDuplicateException extends BaseException{
    public ResourceDuplicateException(String errorCode, String message) {
        super(errorCode, message, HttpStatus.CONFLICT);
    }
}
