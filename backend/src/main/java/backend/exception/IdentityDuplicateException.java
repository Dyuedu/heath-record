package backend.exception;

public class IdentityDuplicateException extends ResourceDuplicateException {
    public IdentityDuplicateException(String identityNumber) {
        super("IDENTITY_DUPLICATE", "CCCD/CMND '" + identityNumber + "' đã tồn tại trong hệ thống.");
    }
}