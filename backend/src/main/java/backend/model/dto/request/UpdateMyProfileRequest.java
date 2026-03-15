package backend.model.dto.request;

public record UpdateMyProfileRequest(
        String fullName,
        String email,
        String phoneNumber,
        String gender,
        String dateOfBirth,
        String address,
        String avatarUrl
) {
}
