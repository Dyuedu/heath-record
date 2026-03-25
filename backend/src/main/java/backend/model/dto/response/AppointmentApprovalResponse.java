package backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AppointmentApprovalResponse {
    
    private Long appointmentId;
    private String status;
    private String message;
    private LocalDateTime respondedAt;
    private AppointmentSlotResponse slotDetails;
}
