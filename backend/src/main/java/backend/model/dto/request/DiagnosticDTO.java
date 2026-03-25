package backend.model.dto.request;

import java.util.List;
import lombok.Data;

@Data
public class DiagnosticDTO {
    private String category;
    private String tag;
    private String type;
    private String data;
    private List<String> imageUrls;
}
