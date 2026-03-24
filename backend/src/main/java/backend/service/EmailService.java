package backend.service;

import backend.exception.InvalidRequestException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class EmailService {
    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;
    private final String fromEmail;
    private final boolean mailEnabled;
    private final boolean debugMailError;

    public EmailService(JavaMailSender mailSender,
                        @Value("${spring.mail.username:}") String fromEmail,
                        @Value("${app.mail.enabled:false}") boolean mailEnabled,
                        @Value("${app.mail.debug-error:true}") boolean debugMailError) {
        this.mailSender = mailSender;
        this.fromEmail = fromEmail;
        this.mailEnabled = mailEnabled;
        this.debugMailError = debugMailError;
    }

    public void sendPasswordOtp(String toEmail, String otp) {
        if (!mailEnabled) {
            // Local development fallback: keep OTP flow functional without SMTP.
            log.warn("Mail is disabled (app.mail.enabled=false). OTP for {} is {}", toEmail, otp);
            return;
        }

        if (fromEmail == null || fromEmail.isBlank()) {
            throw new InvalidRequestException(
                    "MAIL_CONFIG_MISSING",
                    "MAIL_USERNAME is empty. Please configure MAIL_USERNAME and MAIL_PASSWORD"
            );
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setFrom(fromEmail);
            message.setSubject("Password Change OTP");
            message.setText("Your OTP code is: " + otp + "\nThis code expires in 5 minutes.");
            mailSender.send(message);
        } catch (MailException ex) {
            log.error("Failed to send OTP email to {}", toEmail, ex);
            String detail = ex.getMostSpecificCause() != null
                    ? ex.getMostSpecificCause().getMessage()
                    : ex.getMessage();
            String message = "Cannot send OTP email. Please verify MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD";
            if (debugMailError && detail != null && !detail.isBlank()) {
                message = message + " | Cause: " + detail;
            }
            throw new InvalidRequestException(
                    "MAIL_SEND_FAILED",
                    message
            );
        }
    }
    
    public void sendRegistrationOtp(String toEmail, String otp) {
        if (!mailEnabled) {
            log.warn("Mail is disabled (app.mail.enabled=false). Registration OTP for {} is {}", toEmail, otp);
            return;
        }

        if (fromEmail == null || fromEmail.isBlank()) {
            throw new InvalidRequestException(
                    "MAIL_CONFIG_MISSING",
                    "MAIL_USERNAME is empty. Please configure MAIL_USERNAME and MAIL_PASSWORD"
            );
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setFrom(fromEmail);
            message.setSubject("Xác thực Email Đăng ký - Health Record");
            message.setText("Chào bạn,\n\nMã xác thực (OTP) của bạn là: " + otp + "\n\nMã này sẽ hết hạn trong vòng 1 phút.\n\nTrân trọng.");
            mailSender.send(message);
        } catch (MailException ex) {
            log.error("Failed to send Registration OTP email to {}", toEmail, ex);
            throw new InvalidRequestException(
                    "MAIL_SEND_FAILED",
                    "Lỗi gửi email: " + ex.getMessage()
            );
        }
    }
}
