package backend.model.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record AdminUserRequest(
        String fullName,

        @NotBlank(message = "Email không được để trống")
        @Email(message = "Email không hợp lệ")
        String email,

        String phoneNumber,
        
        String identityNumber,

        String password,

        @NotBlank(message = "Vai trò không được để trống")
        String role,

        String gender,
        String dateOfBirth,
        String address,
        String status
) {
}
