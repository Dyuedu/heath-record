package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
public class AddRelativeResultResponse {
    String status;
    UUID requestId;
    String message;
    RelativeResponse relative;
}
