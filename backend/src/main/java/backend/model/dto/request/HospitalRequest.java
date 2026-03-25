package backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;

public record HospitalRequest(
        @NotBlank(message = "Tên bệnh viện không được để trống")
        String name
) {}
