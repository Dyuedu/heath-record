package backend.model.dto.request;

public record ChangePasswordRequest(
	String oldPassword,
	String newPassword
) {
}
