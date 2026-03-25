package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.util.List;

@Value
@Builder
public class DoctorPatientDetailResponse {
    UserResponse patient;
    List<RelativeSearchResponse> relatives;
}
