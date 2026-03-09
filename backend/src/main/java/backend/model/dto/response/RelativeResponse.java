package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
public class RelativeResponse {
    UUID id;
    String name;
    String relationship;
}
