package backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;

public record TagRequest(
        @NotBlank(message = "Tên tag không được để trống")
        String name,
        
        String description
) {}
