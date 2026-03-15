package backend.model.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AttachmentResponse {
    private Long id;
    private String imageUrl;
}
