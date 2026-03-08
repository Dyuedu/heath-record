package backend.util;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Map;

@Getter
@Setter
@Builder
// Chỉ hiển thị field 'validationErrors' trong JSON nếu nó không null (để các lỗi thông thường nhìn gọn hơn)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorResponse {
    private int status;
    private String errorCode;
    private String message;
    private LocalDateTime timestamp;

    // Thêm field này để chứa danh sách lỗi của từng field
    private Map<String, String> validationErrors;
}