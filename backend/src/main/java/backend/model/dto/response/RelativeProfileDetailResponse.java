package backend.model.dto.response;

import java.util.UUID;
import lombok.Builder;

@Builder
public record RelativeProfileDetailResponse(
        UUID profileId,
        UUID relativeId,
        String relativeName,
        String relationship,
        String avatarUrl,
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
