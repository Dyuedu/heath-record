package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
public class LinkRequestActionResponse {
    String status;
    UUID requestId;
    UUID linkedProfileId;
    String message;
}
