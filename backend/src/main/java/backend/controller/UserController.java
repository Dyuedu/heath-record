package backend.controller;

import backend.model.dto.response.PatientDetailResponse;
import backend.model.dto.response.UserResponse;
import backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
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
}
