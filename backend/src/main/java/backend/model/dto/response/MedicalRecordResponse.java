package backend.model.dto.response;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MedicalRecordResponse {
    private Long id;
    private String title;
    private String tag;
    private String note;
    private UUID doctorUserId;
    private String hospitalName; // Chỉ lấy tên bệnh viện thay vì cả object Hospital
    private LocalDateTime datetimeStart;
    private LocalDateTime datetimeEnd;
    private List<String> tagNames; // Chỉ lấy danh sách tên Tag
    
    // Danh sách các chẩn đoán con (chỉ dùng trong bản Detail)
    private List<DiagnosticRecordResponse> diagnosticRecords;
}