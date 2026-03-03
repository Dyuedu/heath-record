package backend.exception;

import backend.util.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidationException(MethodArgumentNotValidException ex) {
        Map<Integer, Error> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(fieldError -> {
            String fieldName = fieldError.getField();
            int index = extractIndex(fieldError.getField());
            String errorMessage = fieldError.getDefaultMessage();

            Error errorObj = errors.computeIfAbsent(index, key -> Error.builder().idx(index).message(new HashMap<>()).build());
            errorObj.getMessage().put(fieldName, errorMessage);
        });

        List<Error> errorList = errors.values().stream().toList();
        ApiResponse<Void> apiResponse = ApiResponse.error(400, errorList);
        return ResponseEntity.badRequest().body(apiResponse);
    }

    private int extractIndex(String fieldPath) {
        try {
            if (fieldPath.contains("[") && fieldPath.contains("]")) {
                return Integer.parseInt(fieldPath.substring(
                        fieldPath.lastIndexOf('[') + 1,
                        fieldPath.lastIndexOf(']')
                ));
            }
        } catch (Exception e) {
            return -1;
        }
        return -1;
    }
}
