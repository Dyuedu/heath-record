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
    private int status;
    private T data;
    private List<Error> errors;

    public static <T> ApiResponse<T> success(int status, T data) {
        return new ApiResponse<>(status, data, null);
    }

    public static <T> ApiResponse<T> error(int status, List<Error> errors) {
        return new ApiResponse<>(status,null, errors);
    }

}
