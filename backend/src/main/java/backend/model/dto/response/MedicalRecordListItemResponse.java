package backend.model.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MedicalRecordListItemResponse {
    private UUID id;

    private String title;

    private LocalDateTime datetimeStart;

    private String doctorName;

    private String hospitalName;

    private Set<String> tags;
}
