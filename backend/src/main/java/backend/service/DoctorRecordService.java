package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.User;
import backend.model.DiagnosticRecord;
import backend.model.Attachment;
import backend.model.Hospital;
import backend.model.Tag;
import backend.model.dto.request.MedicalRecordRequestDTO;
import backend.model.dto.request.DiagnosticDTO;
import backend.model.dto.response.MedicalRecordResponse;
import backend.repository.HospitalRepository;
import backend.repository.TagRepository;
import backend.repository.MedicalRecordRepository;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import backend.service.mapper.MedicalRecordMapper;
import backend.model.dto.response.RelativeSearchResponse;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class DoctorRecordService {

    private final MedicalRecordRepository medicalRecordRepository;
    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;
    private final MedicalRecordMapper medicalRecordMapper;
    private final HospitalRepository hospitalRepository;
    private final TagRepository tagRepository;
    private final RelativeRepository relativeRepository;

    public DoctorRecordService(MedicalRecordRepository medicalRecordRepository,
            ProfileRepository profileRepository,
            UserRepository userRepository,
            MedicalRecordMapper medicalRecordMapper,
            HospitalRepository hospitalRepository,
            TagRepository tagRepository,
            RelativeRepository relativeRepository) {
        this.medicalRecordRepository = medicalRecordRepository;
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
        this.medicalRecordMapper = medicalRecordMapper;
        this.hospitalRepository = hospitalRepository;
        this.tagRepository = tagRepository;
        this.relativeRepository = relativeRepository;
    }

    private String buildAuditField(User doctor) {
        return doctor.getEmail() != null ? "created-by:" + doctor.getEmail() : "created-by:unknown";
    }

    public MedicalRecordResponse createFullMedicalRecord(UUID doctorId, MedicalRecordRequestDTO request) {
        User doctor = userRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Bác sĩ không tồn tại"));

        if (doctor.getRole() == null || !doctor.getRole().getName().equalsIgnoreCase("DOCTOR")) {
            throw new AccessDeniedException("Chỉ bác sĩ mới có quyền tạo bệnh án");
        }

        backend.model.Profile profile = profileRepository.findById(request.getPatientProfileId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ bệnh nhân"));

        backend.model.Relative relative = relativeRepository.findFirstByProfileId(profile.getId()).orElse(null);

        Hospital hospital = null;
        if (request.getHospitalId() != null) {
            hospital = hospitalRepository.findById(request.getHospitalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bệnh viện"));
        }

        MedicalRecord record = MedicalRecord.builder()
                .title(request.getTitle() != null ? request.getTitle().trim() : null)
                .note(request.getNote())
                .doctor(doctor)
                .relative(relative)
                .profile(profile)
                .hospital(hospital)
                .datetimeStart(LocalDateTime.now())
                .datetimeEnd(LocalDateTime.now())
                .auditField(buildAuditField(doctor))
                .build();

        if (request.getDiagnostics() != null && !request.getDiagnostics().isEmpty()) {
            for (DiagnosticDTO diagDTO : request.getDiagnostics()) {
                DiagnosticRecord diagnosticRecord = DiagnosticRecord.builder()
                        .category(diagDTO.getCategory())
                        .tag(diagDTO.getTag())
                        .doctor(doctor.getProfile() != null ? doctor.getProfile().getFullname() : doctor.getEmail())
                        .data(diagDTO.getData())
                        .datetimeEnd(LocalDateTime.now())
                        .auditField(buildAuditField(doctor))
                        .profile(profile)
                        .relative(relative)
                        .encounter(record)
                        .hospital(hospital)
                        .build();

                if (diagDTO.getTag() != null && !diagDTO.getTag().isEmpty()) {
                    Tag tag = tagRepository.findByName(diagDTO.getTag())
                            .orElseGet(() -> tagRepository.save(Tag.builder().name(diagDTO.getTag()).build()));
                    diagnosticRecord.getTags().add(tag);
                }

                if (diagDTO.getImageUrls() != null && !diagDTO.getImageUrls().isEmpty()) {
                    for (String url : diagDTO.getImageUrls()) {
                        Attachment attachment = Attachment.builder()
                                .imageUrl(url)
                                .diagnosticRecord(diagnosticRecord)
                                .build();
                        diagnosticRecord.getAttachments().add(attachment);
                    }
                }
                record.getDiagnosticRecords().add(diagnosticRecord);
            }
        }

        MedicalRecord saved = medicalRecordRepository.save(record);
        return medicalRecordMapper.toMedicalRecordResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<RelativeSearchResponse> searchProfilesForDoctor(String query) {
        return profileRepository.searchProfilesForDoctor(query).stream()
                .map(profile -> {
                    User user = profile.getUser();
                    return RelativeSearchResponse.builder()
                            .id(profile.getId())
                            .fullName(profile.getFullname() != null ? profile.getFullname() : "N/A")
                            .phoneNumber(user != null ? user.getPhoneNumber() : "")
                            .dateOfBirth(profile.getDateOfBirth() != null ? profile.getDateOfBirth() : "")
                            .avatarUrl(profile.getAvatarUrl() != null ? profile.getAvatarUrl() : "")
                            .relationship("Patient")
                            .build();
                })
                .collect(Collectors.toList());
    }
}
