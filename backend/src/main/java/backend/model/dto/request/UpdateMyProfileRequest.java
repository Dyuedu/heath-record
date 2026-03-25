package backend.model.dto.request;

public record UpdateMyProfileRequest(
        String fullName,
        String phoneNumber,
        String gender,
        String dateOfBirth,
        String address,
        String department
) {
}
