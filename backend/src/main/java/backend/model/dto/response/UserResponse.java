package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.sql.Date;
import java.util.UUID;

@Value
@Builder
public class UserResponse {
    UUID id;
    String email;
    String phoneNumber;
    String fullName;
    String role;
    String gender;
    Date dateOfBirth;
    String address;
    String avatarUrl;
}
