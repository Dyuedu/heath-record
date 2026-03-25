package backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DoctorScheduleDayResponse {
    
    private LocalDate date;
    private String dayOfWeek;  // Monday, Tuesday, ...
    private List<AppointmentSlotResponse> slots;
    private int pendingCount;  // Số lượng lịch chờ duyệt
    private int bookedCount;   // Số lượng lịch đã đặt
}
