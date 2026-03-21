package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
public class RelativeResponse {
    UUID id;
    UUID profileId;
    String name;
    String relationship;
    String dateOfBirth;
    String avatarUrl;
}
