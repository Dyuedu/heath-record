package backend.exceptionHandler;

import backend.exception.MultipleResourceDuplicateException;
import backend.exception.ResourceDuplicateException;
import backend.util.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            errors.put(error.getField(), error.getDefaultMessage());
        }
        ErrorResponse errorResponse = ErrorResponse.builder()
                .status(HttpStatus.BAD_REQUEST.value())
                .errorCode("VALIDATION_FAILED")
                .message("Dữ liệu đầu vào không hợp lệ")
                .timestamp(LocalDateTime.now())
                .validationErrors(errors)
                .build();

        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MultipleResourceDuplicateException.class)
    public ResponseEntity<ErrorResponse> handleMultipleDuplicates(MultipleResourceDuplicateException ex) {
        Map<String, String> errorMap = new HashMap<>();
        // Lặp qua danh sách các lỗi con (EmailDuplicate, PhoneDuplicate...)
        for (ResourceDuplicateException subEx : ex.getDuplicateExceptions()) {
            // Giả sử errorCode của Email là "EMAIL_DUPLICATE", bạn có thể cắt chuỗi hoặc map lại key tùy ý
            String fieldName = subEx.getErrorCode().split("_")[0].toLowerCase(); // Lấy chữ "email" hoặc "phone"
            errorMap.put(fieldName, subEx.getMessage());
        }
        ErrorResponse errorResponse = ErrorResponse.builder()
                .status(HttpStatus.CONFLICT.value())
                .errorCode("DUPLICATE_RESOURCE")
                .message("Dữ liệu bị trùng lặp")
                .validationErrors(errorMap)
                .timestamp(LocalDateTime.now())
                .build();

        return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);
    }
}
