package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.Relative;
import backend.model.User;
import backend.model.DiagnosticRecord;
import backend.model.Attachment;
import backend.model.Hospital;
import backend.model.Tag;
import backend.model.dto.request.RecordCreateRequest;
import backend.model.dto.response.MedicalRecordResponse;
import backend.model.dto.response.RelativeHealthHistoryResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import backend.service.mapper.MedicalRecordMapper;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@Transactional
public class RecordService {
    private final MedicalRecordRepository medicalRecordRepository;
    private final RelativeRepository relativeRepository;
    private final UserRepository userRepository;
    private final MedicalRecordMapper medicalRecordMapper;

    public RecordService(MedicalRecordRepository medicalRecordRepository,
            RelativeRepository relativeRepository,
            UserRepository userRepository,
            MedicalRecordMapper medicalRecordMapper) {
        this.medicalRecordRepository = medicalRecordRepository;
        this.relativeRepository = relativeRepository;
        this.userRepository = userRepository;
        this.medicalRecordMapper = medicalRecordMapper;
    }

    public MedicalRecordResponse createRecord(UUID doctorId, RecordCreateRequest request, List<MultipartFile> files) {
        User doctor = userRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Bác sĩ không tồn tại"));

        if (doctor.getRole() == null || !doctor.getRole().getName().equalsIgnoreCase("doctor")) {
            throw new AccessDeniedException("Chỉ bác sĩ mới có quyền tạo bệnh án");
        }

        Relative relative = relativeRepository.findById(request.getRelativeId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ người nhận"));

        MedicalRecord record = MedicalRecord.builder()
                .title(request.getTitle() != null ? request.getTitle().trim() : null)
                .tag(resolvePrimaryTag(request))
                .note(request.getNotes())
                .doctor(doctor)
                .relative(relative)
                .profile(relative.getProfile())
                .datetimeStart(LocalDateTime.now())
                .datetimeEnd(LocalDateTime.now())
                .auditField(buildAuditField(doctor))
                .build();

        MedicalRecord saved = medicalRecordRepository.save(record);
        return medicalRecordMapper.toMedicalRecordResponse(saved);
    }

    public RelativeHealthHistoryResponse getRecordsByRelative(UUID userId, UUID relativeId) {
        Relative relative = relativeRepository.findById(relativeId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người thân"));

        if (!relative.getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Relative không thuộc user này");
        }

        List<MedicalRecord> records = medicalRecordRepository.findByRelativeId(relativeId);
        return medicalRecordMapper.toRelativeHistory(relative, records);
    }

    public RelativeHealthHistoryResponse getRecordsByProfile(UUID userId, UUID profileId) {
        Relative relative = relativeRepository.findFirstByUserIdAndProfileId(userId, profileId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người thân"));

        List<MedicalRecord> records = medicalRecordRepository.findByProfileId(profileId);
        return medicalRecordMapper.toRelativeHistory(relative, records);
    }

    public MedicalRecordResponse getRecordById(UUID userId, Long recordId) {
        MedicalRecord record = medicalRecordRepository.findById(recordId)
                .orElseThrow(() -> new ResourceNotFoundException("Bệnh án không tồn tại hoặc đã bị xóa"));

        boolean isPatient = record.getRelative() != null && 
                            record.getRelative().getUser() != null && 
                            record.getRelative().getUser().getId().equals(userId);
        boolean isDoctor = record.getDoctor() != null && 
                           record.getDoctor().getId().equals(userId);

        if (!isPatient && !isDoctor) {
            throw new AccessDeniedException("Bạn không có quyền xem bệnh án này");
        }

        return medicalRecordMapper.toMedicalRecordResponse(record);
    }

    private String resolvePrimaryTag(RecordCreateRequest request) {
        if (request.getTags() != null && !request.getTags().isEmpty()) {
            return request.getTags().get(0);
        }
        return request.getType();
    }

    private String buildAuditField(User doctor) {
        return doctor.getEmail() != null ? "created-by:" + doctor.getEmail() : "created-by:unknown";
    }

}
