package backend.model.dto.request;

public record LoginRequest(
        String email,
        String password
) {}
