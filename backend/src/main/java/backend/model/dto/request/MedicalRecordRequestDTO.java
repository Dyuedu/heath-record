package backend.model.dto.request;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
public class MedicalRecordRequestDTO {
    @NotNull(message = "Patient Profile ID is required")
    private UUID patientProfileId;
    
    // hospitalId is optional, as it may be handled differently in the form
    private Long hospitalId;
    
    @NotBlank(message = "Title is required")
    private String title;
    
    private String note;
    
    private String tag;
    
    private LocalDateTime datetimeEnd;
    
    private List<DiagnosticDTO> diagnostics;
}
