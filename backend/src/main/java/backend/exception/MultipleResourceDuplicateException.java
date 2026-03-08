package backend.exception;

import lombok.Getter;

import java.util.List;

/**
 * This exception is thrown when multiple resource conflicts are detected during an operation.
 * The purpose of this exception is to aggregate multiple instances of {@link ResourceDuplicateException}
 * into a single exception, allowing the caller to handle all detected resource duplication issues
 * at once.
 *
 * The exceptions detailing the specific resource conflicts are stored in a list of
 * {@link ResourceDuplicateException} instances.
 */

@Getter
public class MultipleResourceDuplicateException extends RuntimeException{
    private final List<ResourceDuplicateException> duplicateExceptions;

    public MultipleResourceDuplicateException(List<ResourceDuplicateException> duplicateExceptionList) {
        this.duplicateExceptions = duplicateExceptionList;
    }
}
