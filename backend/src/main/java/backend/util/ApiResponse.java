package backend.util;
import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.*;

import java.util.List;
import backend.exception.Error;


@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    private Integer code;
    private T data;
    private List<Error> errors;
    private String message;

    public static <T> ApiResponse<T> success(Integer code, T data, String message) {
        return new ApiResponse<>(code, data, null, message);
    }

    public static <T> ApiResponse<T> error(Integer code, List<Error> errors) {
        return new ApiResponse<>(code,null, errors, null);
    }

}
