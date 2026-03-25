package backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationMessageDTO {
    private UUID id;
    private String title;
    private String message;
    private String patientName;
    private String doctorName;
    private String hospitalName;
    private String recordId;
    private boolean isRead;
    private LocalDateTime timestamp;
}
