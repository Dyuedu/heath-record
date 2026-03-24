package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

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
}
