package backend.model.dto.response;

import java.time.LocalDateTime;
import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DiagnosticRecordResponse {
private Long id;
    private String category;
    private String tag;
    private String doctor;
    private String data; // Nội dung JSON đã parse hoặc chuỗi text
    private LocalDateTime datetimeEnd;
    private String hospitalName;
    private List<String> tagNames;
    private List<AttachmentResponse> attachments; // Các file ảnh đính kè
}
