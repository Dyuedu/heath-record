package backend.exception;

public class PhoneDuplicateException extends ResourceDuplicateException{
    public PhoneDuplicateException(String phone) {
        super("PHONE_DUPLICATE", "Số điện thoại " + phone + " đã được sử dụng");
    }
}
