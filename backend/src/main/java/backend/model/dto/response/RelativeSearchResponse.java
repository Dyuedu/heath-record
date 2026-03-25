package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;
import java.util.UUID;

@Value
@Builder
public class RelativeSearchResponse {
    UUID id;
    String fullName;
    String phoneNumber;
    String dateOfBirth;
    String avatarUrl;
    String relationship;
    String identityNumber;
    String address;
}
