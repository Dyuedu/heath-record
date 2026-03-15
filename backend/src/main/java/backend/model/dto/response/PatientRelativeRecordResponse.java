package backend.model.dto.response;

import java.util.List;
import java.util.UUID;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class PatientRelativeRecordResponse {
    UUID id;
    String name;
    String relationship;
    List<RecordResponse> records;
}
