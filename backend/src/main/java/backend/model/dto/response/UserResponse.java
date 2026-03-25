package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.time.LocalDateTime;
import java.util.UUID;

@Value
@Builder
public class UserResponse {
    UUID id;
    String email;
    String phoneNumber;
    String identityNumber;
    String fullName;
    String role;
    String gender;
    String dateOfBirth;
    String address;
    String avatarUrl;
    String status;
    String cccdFrontUrl;
    String cccdBackUrl;
    String diplomaUrl;
    String allergy;
    String chronicDisease;
    String clinicalNotes;
    String bloodGroup;
    LocalDateTime createdAt;
}
