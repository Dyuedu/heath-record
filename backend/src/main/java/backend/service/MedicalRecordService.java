package backend.service;

import backend.mapper.MedicalRecordMapper;
import backend.model.dto.response.MedicalRecordListItemResponse;
import backend.repository.MedicalRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MedicalRecordService {
    private final MedicalRecordRepository medicalRecordRepository;
    private final MedicalRecordMapper medicalRecordMapper;

    public Page<MedicalRecordListItemResponse> getByProfile(UUID profileId, Pageable pageable) {

        return medicalRecordRepository
                .findByProfileId(profileId, pageable)
                .map(medicalRecordMapper::mapToListItem);
    }
}
