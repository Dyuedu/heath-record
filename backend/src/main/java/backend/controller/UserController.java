package backend.controller;

import backend.model.UserPrincipal;
import backend.model.dto.request.ChangePasswordRequest;
import backend.model.dto.request.UpdateMyProfileRequest;
import backend.model.dto.request.VerifyOtpRequest;
import backend.model.dto.response.PatientDetailResponse;
import backend.model.dto.response.UserResponse;
import backend.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/doctor/search-patients")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<List<UserResponse>> searchPatients(
            @RequestParam String phone) {
        List<UserResponse> patients = userService.searchPatients(phone);
        return ResponseEntity.ok(patients);
    }

    @GetMapping("/doctor/patients/{patientId}")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<PatientDetailResponse> getPatientDetail(
            @PathVariable UUID patientId) {
        return ResponseEntity.ok(userService.getPatientDetail(patientId));
    }

    @GetMapping("/users/me")
    public ResponseEntity<UserResponse> getMyProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(userService.getCurrentUser(userPrincipal.getId()));
    }

    @PutMapping("/users/me/password")
    public ResponseEntity<Map<String, String>> updateMyPassword(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody ChangePasswordRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(userService.updateMyPassword(userPrincipal.getId(), request));
    }

    @PostMapping("/users/me/password/verify-otp")
    public ResponseEntity<Map<String, String>> verifyMyPasswordOtp(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody VerifyOtpRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(userService.verifyMyPasswordOtp(userPrincipal.getId(), request));
    }

    @PutMapping("/users/me")
    public ResponseEntity<UserResponse> updateMyProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody UpdateMyProfileRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(userService.updateCurrentUser(userPrincipal.getId(), request));
    }

    @PutMapping(value = "/users/me/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<UserResponse> updateMyAvatar(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestPart("avatar") MultipartFile avatarFile) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(userService.updateMyAvatar(userPrincipal.getId(), avatarFile));
    }
}
