package backend.service;

import backend.exception.InvalidRequestException;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

@Service
public class EmailService {
    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;
    private final String fromEmail;
    private final boolean mailEnabled;
    private final boolean debugMailError;
    private final TemplateEngine templateEngine;

    public EmailService(JavaMailSender mailSender,
                        @Value("${spring.mail.username:}") String fromEmail,
                        @Value("${app.mail.enabled:false}") boolean mailEnabled,
                        @Value("${app.mail.debug-error:true}") boolean debugMailError,
                        TemplateEngine templateEngine) {
        this.mailSender = mailSender;
        this.fromEmail = fromEmail;
        this.mailEnabled = mailEnabled;
        this.debugMailError = debugMailError;
        this.templateEngine = templateEngine;
    }

    public void sendPasswordOtp(String toEmail, String otp) {
        if (!mailEnabled) {
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

    public void sendDoctorActivationEmail(String toEmail, String activationLink) {
        if (!mailEnabled) {
            log.warn("Mail is disabled (app.mail.enabled=false). Doctor activation link for {} is {}", toEmail, activationLink);
            return;
        }

        if (fromEmail == null || fromEmail.isBlank()) {
            throw new InvalidRequestException(
                    "MAIL_CONFIG_MISSING",
                    "MAIL_USERNAME is empty. Please configure MAIL_USERNAME and MAIL_PASSWORD"
            );
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(toEmail);
            helper.setFrom(fromEmail);
            helper.setSubject("Kich hoat tai khoan Bac si - Health Record");

            String htmlBody = """
                            <html>
                                <body style="font-family: Arial, sans-serif; color: #1f2937; line-height: 1.6;">
                                    <p>Xin chao,</p>
                                    <p>Tai khoan bac si cua ban da duoc tao boi quan tri vien.</p>
                                    <p>Vui long nhan vao nut ben duoi de kich hoat tai khoan:</p>
                                    <p style="margin: 24px 0;">
                                        <a href="%s" style="display:inline-block;padding:12px 24px;background:#246BFF;color:#ffffff;text-decoration:none;border-radius:10px;font-weight:700;">Kich hoat tai khoan</a>
                                    </p>
                                    <p>Nut kich hoat se het han sau 24 gio.</p>
                                    <p>Tran trong.</p>
                                </body>
                            </html>
                            """.formatted(activationLink);

            helper.setText(htmlBody, true);
            mailSender.send(message);
        } catch (MailException | MessagingException ex) {
            log.error("Failed to send doctor activation email to {}", toEmail, ex);
            String detail;
            if (ex instanceof MailException mailException && mailException.getMostSpecificCause() != null) {
                detail = mailException.getMostSpecificCause().getMessage();
            } else {
                detail = ex.getMessage();
            }
            String message = "Cannot send activation email. Please verify MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD";
            if (debugMailError && detail != null && !detail.isBlank()) {
                message = message + " | Cause: " + detail;
            }
            throw new InvalidRequestException("MAIL_SEND_FAILED", message);
        }
    }

    public void sendAppointmentDecisionEmail(
            String toEmail,
            String patientName,
            String doctorName,
            LocalDate appointmentDate,
            LocalTime slotStart,
            LocalTime slotEnd,
            boolean approved,
            String reason) {
        if (!mailEnabled) {
            log.info("Mail disabled. Appointment decision for {} -> approved={} reason={}", toEmail, approved, reason);
            return;
        }
        if (fromEmail == null || fromEmail.isBlank()) {
            throw new InvalidRequestException(
                    "MAIL_CONFIG_MISSING",
                    "MAIL_USERNAME is empty. Please configure MAIL_USERNAME and MAIL_PASSWORD"
            );
        }

        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        String subject = approved
                ? "Lịch khám của bạn đã được xác nhận"
                : "Lịch khám của bạn đã bị từ chối";
        String greeting = StringUtils.hasText(patientName)
                ? "Chào " + patientName + ","
                : "Chào bạn,";
        String statusLine = approved
                ? "Bác sĩ " + doctorName + " đã chấp thuận lịch khám của bạn."
                : "Bác sĩ " + doctorName + " đã cập nhật lịch khám: " + (reason != null ? reason : "");
        String reasonLine = !approved && StringUtils.hasText(reason)
                ? "\nLý do: " + reason + ""
                : "";
        String body = greeting + "\n\n" + statusLine + "\n" +
                "Thời gian: " + appointmentDate.format(dateFormatter) + " " +
                slotStart.format(timeFormatter) + " - " + slotEnd.format(timeFormatter) +
                reasonLine + "\n\nTrân trọng.";

        try {
            if (approved) {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setTo(toEmail);
                message.setFrom(fromEmail);
                message.setSubject(subject);
                message.setText(body);
                mailSender.send(message);
            } else {
                Context context = new Context();
                context.setVariable("patientName", StringUtils.hasText(patientName) ? patientName : "bạn");
                context.setVariable("doctorName", doctorName);
                context.setVariable("appointmentDate", appointmentDate.format(dateFormatter));
                context.setVariable("slotRange", slotStart.format(timeFormatter) + " - " + slotEnd.format(timeFormatter));
                context.setVariable("reason", StringUtils.hasText(reason) ? reason : "Bác sĩ đã điều chỉnh lịch khám của bạn.");

                String htmlBody = templateEngine.process("appointment-rejection", context);

                MimeMessage message = mailSender.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(message, "UTF-8");
                helper.setTo(toEmail);
                helper.setFrom(fromEmail);
                helper.setSubject(subject);
                helper.setText(htmlBody, true);
                mailSender.send(message);
            }
        } catch (MailException | MessagingException ex) {
            log.error("Failed to send appointment decision email to {}", toEmail, ex);
            if (debugMailError) {
                // ✅ FIX: Wrap thành RuntimeException hoặc throw InvalidRequestException
                throw new RuntimeException("Failed to send appointment decision email", ex);
            }
        }
    }
}