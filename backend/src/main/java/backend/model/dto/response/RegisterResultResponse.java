package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
public class RegisterResultResponse {
    String status;
    UUID requestId;
    String message;
}
