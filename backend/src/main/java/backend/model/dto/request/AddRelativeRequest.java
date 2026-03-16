package backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;

public record AddRelativeRequest(
        @NotBlank(message = "Họ tên không được để trống")
        String fullname,

        @NotBlank(message = "Tên thân mật không được để trống")
        String nickname,

        @NotBlank(message = "Giới tính không được để trống")
        String gender,

        @NotBlank(message = "Ngày sinh không được để trống")
        String dateOfBirth,

        @NotBlank(message = "Số điện thoại không được để trống")
        String phoneNumber,

        @NotBlank(message = "Mối quan hệ không được để trống")
        String relationship
) {
}
