package backend.controller;

import backend.model.dto.request.LoginRequest;
import backend.model.dto.request.RegisterRequest;
import backend.model.dto.response.RegisterResultResponse;
import backend.service.AdminUserService;
import backend.service.AuthService;
import jakarta.validation.Valid;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.LockedException;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;
    private final AdminUserService adminUserService;
    private final String activationResultDeepLinkTemplate;
    private final String activationFallbackUrl;

    public AuthController(AuthService authService,
                          AdminUserService adminUserService,
                          @Value("${app.doctor.activation-result-deeplink-template:healthrecord://activation?status={status}&message={message}}")
                          String activationResultDeepLinkTemplate,
                          @Value("${app.doctor.activation-fallback-url:https://play.google.com/store/apps/details?id=com.example.frontend}")
                          String activationFallbackUrl) {
        this.authService = authService;
        this.adminUserService = adminUserService;
        this.activationResultDeepLinkTemplate = activationResultDeepLinkTemplate;
        this.activationFallbackUrl = activationFallbackUrl;
    }

    @PostMapping("/register")
     public ResponseEntity<RegisterResultResponse> register(@Valid @RequestBody RegisterRequest registerRequest){
         RegisterResultResponse result = authService.register(registerRequest);
         return ResponseEntity.ok(result);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest){
        try {
            String token = authService.login(loginRequest);
            Map<String, String> response = new HashMap<>();
            response.put("token", token);
            return ResponseEntity.ok().body(response);
        } catch (BadCredentialsException e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "Email hoặc mật khẩu không chính xác");
            return ResponseEntity.badRequest().body(error);
        } catch (LockedException e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "Tài khoản đã bị khoá, vui lòng liên hệ ban quản lý");
            return ResponseEntity.badRequest().body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> request) {
        try {
            authService.verifyOtp(request.get("email"), request.get("otp"));
            Map<String, String> response = new HashMap<>();
            response.put("message", "Xác thực thành công");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PostMapping("/resend-otp")
    public ResponseEntity<?> resendOtp(@RequestBody Map<String, String> request) {
        try {
            authService.resendOtp(request.get("email"));
            Map<String, String> response = new HashMap<>();
            response.put("message", "Đã gửi lại mã OTP");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @GetMapping("/activate-doctor")
    public ResponseEntity<?> activateDoctor(@RequestParam("token") String token) {
        String status;
        String message;
        try {
            adminUserService.activateDoctorAccount(token);
            status = "success";
            message = "Kich hoat tai khoan thanh cong";
        } catch (Exception e) {
            status = "failed";
            message = e.getMessage();
        }

        URI deepLinkUri = buildActivationResultUri(status, message);
        String html = buildActivationLandingPage(deepLinkUri.toString(), activationFallbackUrl, status, message);

        return ResponseEntity.status(HttpStatus.OK)
                .contentType(MediaType.TEXT_HTML)
                .header("Cache-Control", "no-store, no-cache, must-revalidate")
                .body(html);
    }

    private URI buildActivationResultUri(String status, String message) {
        String safeStatus = status == null ? "failed" : status;
        String safeMessage = message == null ? "Unknown" : message;
        String encodedMessage = URLEncoder.encode(safeMessage, StandardCharsets.UTF_8);

        String uri = activationResultDeepLinkTemplate
                .replace("{status}", safeStatus)
                .replace("{message}", encodedMessage);
        return URI.create(uri);
    }

        private String buildActivationLandingPage(String deepLink, String fallbackUrl, String status, String message) {
                String title = "success".equalsIgnoreCase(status)
                                ? "Tai khoan da duoc kich hoat"
                                : "Kich hoat tai khoan khong thanh cong";
                String description = sanitizeHtml(message == null || message.isBlank()
                                ? "Vui long mo ung dung de tiep tuc."
                                : message);
                String safeDeepLink = sanitizeHtmlAttribute(deepLink);
                String safeFallback = sanitizeHtmlAttribute(fallbackUrl);
                String safeDeepLinkJs = sanitizeJs(deepLink);
                String safeFallbackJs = sanitizeJs(fallbackUrl);

                return """
                                <!doctype html>
                                <html lang=\"vi\">
                                <head>
                                    <meta charset=\"utf-8\" />
                                    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
                                    <title>Kich hoat tai khoan</title>
                                    <style>
                                        body { font-family: Arial, sans-serif; background: #f3f6fb; margin: 0; padding: 24px; color: #1f2937; }
                                        .card { max-width: 520px; margin: 48px auto; background: #ffffff; border-radius: 16px; padding: 24px; box-shadow: 0 12px 32px rgba(15, 23, 42, 0.08); }
                                        h1 { margin: 0 0 12px; font-size: 24px; }
                                        p { margin: 0 0 20px; line-height: 1.6; }
                                        .btn { display: inline-block; border-radius: 10px; padding: 12px 18px; text-decoration: none; font-weight: 700; }
                                        .btn-primary { background: #246bff; color: #ffffff; }
                                        .btn-secondary { background: #e5e7eb; color: #111827; margin-left: 8px; }
                                        .hint { margin-top: 14px; font-size: 14px; color: #6b7280; }
                                    </style>
                                </head>
                                <body>
                                    <div class=\"card\">
                                        <h1>%s</h1>
                                        <p>%s</p>
                                        <a class=\"btn btn-primary\" href=\"%s\">Mo ung dung</a>
                                        <a class=\"btn btn-secondary\" href=\"%s\">Mo trang du phong</a>
                                        <p class=\"hint\">Neu app khong tu dong mo, vui long nhan vao nut \"Mo ung dung\".</p>
                                    </div>

                                    <script>
                                        (function () {
                                            var deepLink = \"%s\";
                                            var fallbackUrl = \"%s\";

                                            window.location.href = deepLink;

                                            setTimeout(function () {
                                                window.location.href = fallbackUrl;
                                            }, 1800);
                                        })();
                                    </script>
                                </body>
                                </html>
                                """.formatted(sanitizeHtml(title), description, safeDeepLink, safeFallback, safeDeepLinkJs, safeFallbackJs);
        }

        private String sanitizeHtml(String value) {
                if (value == null) {
                        return "";
                }
                return value
                                .replace("&", "&amp;")
                                .replace("<", "&lt;")
                                .replace(">", "&gt;")
                                .replace("\"", "&quot;")
                                .replace("'", "&#39;");
        }

        private String sanitizeHtmlAttribute(String value) {
                return sanitizeHtml(value).replace("`", "");
        }

        private String sanitizeJs(String value) {
                if (value == null) {
                        return "";
                }
                return value
                                .replace("\\", "\\\\")
                                .replace("\"", "\\\"")
                                .replace("\n", "")
                                .replace("\r", "");
        }
}
