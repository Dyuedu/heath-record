package backend.model.dto.response;

import backend.model.RequestStatus;
import backend.model.RequestType;
import lombok.Builder;
import lombok.Value;

import java.time.LocalDateTime;
import java.util.UUID;

@Value
@Builder
public class LinkRequestResponse {
    UUID requestId;
    UUID requesterUserId;
    UUID ownerUserId;
    UUID targetProfileId;
    String targetProfileName;
    RequestType requestType;
    String requestedRelationship;
    String note;
    RequestStatus status;
    LocalDateTime expiresAt;
    LocalDateTime respondedAt;
    LocalDateTime createdAt;
}
