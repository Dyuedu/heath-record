package backend.controller;

import backend.model.dto.response.MedicalRecordListItemResponse;
import backend.service.MedicalRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/medical-records")
@RequiredArgsConstructor
public class MedicalRecordController {

    private final MedicalRecordService medicalRecordService;

    @GetMapping("/profile/{profileId}")
    public Page<MedicalRecordListItemResponse> getMedicalRecordsByProfile(
            @PathVariable UUID profileId,
            Pageable pageable
    ) {
        return medicalRecordService.getByProfile(profileId, pageable);
    }
}
