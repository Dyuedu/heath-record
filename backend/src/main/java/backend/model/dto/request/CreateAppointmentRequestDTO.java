package backend.model.dto.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateAppointmentRequestDTO {
    
    @NotNull(message = "Ngày hẹn không được để trống")
    private LocalDate appointmentDate;
    
    @NotNull(message = "Số slot không được để trống")
    @Min(value = 1, message = "Slot phải từ 1 đến 8")
    @Max(value = 8, message = "Slot phải từ 1 đến 8")
    private Integer slotNumber;
    
    @NotBlank(message = "Tên bệnh nhân không được để trống")
    private String patientName;
    
    @NotBlank(message = "Số điện thoại bệnh nhân không được để trống")
    @Pattern(regexp = "^\\d{10,11}$", message = "Số điện thoại không hợp lệ")
    private String patientPhone;
    
    private String notes;
}
