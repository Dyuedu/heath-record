package backend.model.dto.response;

import java.util.List;
import java.util.UUID;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelativeHealthHistoryResponse {
    private UUID relativeId;
    private UUID patientProfileId;
    private String relativeName; // Lấy từ Profile gắn với Relative
    private String relationship;
    private List<MedicalRecordResponse> history; // Danh sách các cuộc khám bệnh
}