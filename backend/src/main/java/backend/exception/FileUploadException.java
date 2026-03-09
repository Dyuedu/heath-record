package backend.exception;

import org.springframework.http.HttpStatus;

public class FileUploadException extends BaseException {
    public FileUploadException(String message) {
        super("FILE_UPLOAD_FAILED", message, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    public FileUploadException(String message, Throwable cause) {
        this(message);
        initCause(cause);
    }
}
