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
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.authentication.LockedException;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;
    private final AdminUserService adminUserService;
    private final String activationResultDeepLinkTemplate;

    public AuthController(AuthService authService,
                          AdminUserService adminUserService,
                          @Value("${app.doctor.activation-result-deeplink-template:healthrecord://activation?status={status}&message={message}}")
                          String activationResultDeepLinkTemplate) {
        this.authService = authService;
        this.adminUserService = adminUserService;
        this.activationResultDeepLinkTemplate = activationResultDeepLinkTemplate;
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
        try {
            adminUserService.activateDoctorAccount(token);
            URI successUri = buildActivationResultUri("success", "Kich hoat tai khoan thanh cong");
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(successUri)
                    .build();
        } catch (Exception e) {
            URI failedUri = buildActivationResultUri("failed", e.getMessage());
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(failedUri)
                    .build();
        }
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
}
