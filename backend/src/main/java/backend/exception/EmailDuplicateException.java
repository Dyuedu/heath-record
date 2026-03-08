package backend.exception;

import org.springframework.http.HttpStatus;

public class EmailDuplicateException extends ResourceDuplicateException{
    public EmailDuplicateException(String email){
        super("EMAIL_DUPLICATE", "Email '" + email + "' đã tồn tại trong hệ thống.");
    }
}
