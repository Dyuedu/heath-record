package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class HospitalResponse {
    Long id;
    String name;
    boolean isActive;
}
