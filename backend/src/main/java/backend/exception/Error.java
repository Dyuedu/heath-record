package backend.exception;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

@Data
@Builder
public class Error {
    private int idx;
    private Map<String, String> message;
}