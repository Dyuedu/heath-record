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

    /**
     * Handles validation exceptions thrown during the processing of method arguments.
     * The method captures field-specific validation errors, organizes them in a map,
     * and returns a standardized error response.
     *
     * @param ex the {@link MethodArgumentNotValidException} containing validation errors.
     * @return a {@link ResponseEntity} containing an {@link ErrorResponse} with details about
     *         the validation failures, including the field-specific errors.
     */
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

    /**
     * Handles exceptions of type {@link MultipleResourceDuplicateException} that indicate
     * multiple resource duplication issues. It processes the individual duplicate errors,
     * maps them to their respective fields, and constructs a standardized error response.
     *
     * @param ex the {@link MultipleResourceDuplicateException} containing details about the
     *           duplicated resources.
     * @return a {@link ResponseEntity} containing an {@link ErrorResponse} with information about
     *         the duplicate issues, including field-specific error messages and metadata.
     */
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
