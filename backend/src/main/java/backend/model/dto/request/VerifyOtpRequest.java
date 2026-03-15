package backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;

public record VerifyOtpRequest(
        @NotBlank(message = "OTP is required")
        String otp
) {
}
