package backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AppointmentApprovalRequestDTO {
    
    @NotNull(message = "ID lịch khám không được để trống")
    private Long appointmentId;
    
    @NotNull(message = "Hành động không được để trống")
    private Boolean approve;  // true = BOOKED, false = REJECTED
    
    private String notes;
}
