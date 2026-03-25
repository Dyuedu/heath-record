package backend.exception;

import org.springframework.http.HttpStatus;

public class EmailDuplicateException extends ResourceDuplicateException{
    public EmailDuplicateException(String email){
        super("EMAIL_DUPLICATE", "Email đã tồn tại trong hệ thống, vui lòng sử dụng email khác");
    }
}
