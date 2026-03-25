package backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AppointmentDetailResponse {
    private Long appointmentId;
    private LocalDate appointmentDate;
    private Integer slotNumber;
    private LocalTime slotStartTime;
    private LocalTime slotEndTime;
    private String status;
    private BasicUserInfo doctor;
    private BasicUserInfo patient;
    private String patientName;
    private String patientPhone;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime respondedAt;
}
