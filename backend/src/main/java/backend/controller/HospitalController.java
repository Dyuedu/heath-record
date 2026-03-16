package backend.controller;

import backend.model.dto.response.HospitalResponse;
import backend.repository.HospitalRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class HospitalController {
    private final HospitalRepository hospitalRepository;

    public HospitalController(HospitalRepository hospitalRepository) {
        this.hospitalRepository = hospitalRepository;
    }

    @GetMapping("/hospitals")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<List<HospitalResponse>> getAllHospitals() {
        List<HospitalResponse> responses = hospitalRepository.findAll().stream()
                .map(hospital -> HospitalResponse.builder()
                        .id(hospital.getId())
                        .name(hospital.getName())
                        .build())
                .toList();
        return ResponseEntity.ok(responses);
    }
}
