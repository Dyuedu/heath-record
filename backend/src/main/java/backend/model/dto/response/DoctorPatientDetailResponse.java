package backend.model.dto.response;

import lombok.Builder;
import lombok.Value;

import java.util.List;

import backend.model.dto.response.RelativeHealthHistoryResponse;

@Value
@Builder
public class DoctorPatientDetailResponse {
    UserResponse patient;
    List<RelativeHealthHistoryResponse> relatives;
}
