package backend.model.dto.request;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class RecordCreateRequest {
    @NotBlank(message = "Tiêu đề không được để trống")
    private String title;

    private String notes;

    private String type;

    private List<String> tags = new ArrayList<>();

    private boolean important;

    private UUID relativeId;
}
