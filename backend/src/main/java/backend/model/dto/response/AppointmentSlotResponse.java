package backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AppointmentSlotResponse {
    
    private Long appointmentId;
    private Integer slotNumber;
    private LocalTime slotStartTime;
    private LocalTime slotEndTime;
    private String status;  // AVAILABLE, PENDING, BOOKED, REJECTED, CANCELLED
    
    // Thông tin bệnh nhân khi status là PENDING
    private String patientName;
    private String patientPhone;
    private String notes;
}
