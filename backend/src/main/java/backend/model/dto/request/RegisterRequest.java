package backend.model.dto.request;

import jakarta.validation.constraints.*;

public record RegisterRequest(
        @NotBlank(message = "fullname is required")
        String fullname,
        String identityNumber,
        Boolean confirmLinkRequest,
        @NotBlank(message = "Email is required")
        @Email(message = "Email format is invalid")
        String email,
        @NotBlank(message = "Phone is required")
        String phone,
        @NotBlank(message = "Password is required")
        @Size(min = 6, max = 20, message = "Password must be between 8 and 20 characters")
        String password
) {}
