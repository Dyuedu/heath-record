package backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BasicUserInfo {
    private UUID id;
    private String fullName;
    private String phoneNumber;
    private String email;
    private String avatarUrl;
}
