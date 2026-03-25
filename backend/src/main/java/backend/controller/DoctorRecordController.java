package backend.controller;

import backend.model.UserPrincipal;
import backend.model.dto.request.MedicalRecordRequestDTO;
import backend.model.dto.response.MedicalRecordResponse;
import backend.model.dto.response.RelativeSearchResponse;
import backend.service.DoctorRecordService;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/doctor/records")
@Validated
public class DoctorRecordController {

    private final DoctorRecordService doctorRecordService;

    public DoctorRecordController(DoctorRecordService doctorRecordService) {
        this.doctorRecordService = doctorRecordService;
    }

    @PostMapping
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<MedicalRecordResponse> createFullMedicalRecord(
            @RequestBody @Valid MedicalRecordRequestDTO request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        MedicalRecordResponse response = doctorRecordService.createFullMedicalRecord(userPrincipal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/profiles/search")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<List<RelativeSearchResponse>> searchProfiles(@RequestParam("query") String query) {
        return ResponseEntity.ok(doctorRecordService.searchProfilesForDoctor(query));
    }

    @GetMapping("/patients/{profileId}/detail")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<backend.model.dto.response.DoctorPatientDetailResponse> getPatientDetail(@PathVariable java.util.UUID profileId) {
        return ResponseEntity.ok(doctorRecordService.getPatientDetail(profileId));
    }
}
