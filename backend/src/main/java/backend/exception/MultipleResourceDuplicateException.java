package backend.exception;

import lombok.Getter;

import java.util.List;

@Getter
public class MultipleResourceDuplicateException extends RuntimeException{
    private final List<ResourceDuplicateException> duplicateExceptions;

    public MultipleResourceDuplicateException(List<ResourceDuplicateException> duplicateExceptionList) {
        this.duplicateExceptions = duplicateExceptionList;
    }
}
