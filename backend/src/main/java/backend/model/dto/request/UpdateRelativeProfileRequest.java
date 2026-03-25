package backend.model.dto.request;

public record UpdateRelativeProfileRequest(
        String fullName,
        String nickname,
        String identityNumber,
        String gender,
        String dateOfBirth,
        String phoneNumber,
        String address,
        String allergy,
        String chronicDisease,
        String clinicalNotes,
        String bloodGroup
) {
}
