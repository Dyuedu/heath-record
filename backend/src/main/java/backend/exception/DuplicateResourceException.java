package backend.exception;

import lombok.Getter;

@Getter
public class DuplicateResourceException extends RuntimeException{
    private final int index;
    private final String field;

    public DuplicateResourceException(int index, String field, String message) {
        super(message);
        this.index = index;
        this.field = field;
    }
}
