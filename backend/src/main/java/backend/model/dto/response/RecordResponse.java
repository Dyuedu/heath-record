package backend.model.dto.response;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class RecordResponse {
    UUID id;
    String title;
    String notes;
    boolean important;
    String type;
    List<String> tags;
    List<String> attachments;
    LocalDateTime createdAt;
    UUID relativeId;
    UUID patientProfileId;
    String relativeName;
    String patientName;
    String doctorName;
}
