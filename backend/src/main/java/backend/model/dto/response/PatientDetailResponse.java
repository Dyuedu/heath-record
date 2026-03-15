package backend.model.dto.response;

import java.util.List;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class PatientDetailResponse {
    UserResponse patient;
    List<RelativeHealthHistoryResponse> relatives;
}
