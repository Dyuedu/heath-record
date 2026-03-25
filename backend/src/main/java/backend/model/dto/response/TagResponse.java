package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class TagResponse {
    Long id;
    String name;
    String description;
    boolean isActive;
}
