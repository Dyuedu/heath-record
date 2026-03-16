package backend.model.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record AdminUserRequest(
        @NotBlank(message = "Họ tên không được để trống")
        String fullName,

        @NotBlank(message = "Email không được để trống")
        @Email(message = "Email không hợp lệ")
        String email,

        @NotBlank(message = "Số điện thoại không được để trống")
        String phoneNumber,

        String password,

        @NotBlank(message = "Vai trò không được để trống")
        String role,

        String gender,
        String dateOfBirth,
        String address
) {
}
