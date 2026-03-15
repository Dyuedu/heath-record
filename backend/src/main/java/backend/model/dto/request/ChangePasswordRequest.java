package backend.model.dto.request;

public record ChangePasswordRequest(
	String otp,
	String newPassword
) {
}
