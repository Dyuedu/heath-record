package backend.model.dto.request;

public record UpdateMyProfileRequest(
        String fullName,
        String phoneNumber,
        String gender,
        String dateOfBirth,
        String address,
        String allergy,
        String chronicDisease,
        String clinicalNotes,
        String bloodGroup
) {
}
