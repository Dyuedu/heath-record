package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.Relative;
import backend.model.User;
import backend.model.DiagnosticRecord;
import backend.model.Attachment;
import backend.model.Hospital;
import backend.model.Profile;
import backend.model.Tag;
import backend.model.dto.request.RecordCreateRequest;
import backend.model.dto.request.UpdateRelativeProfileRequest;
import backend.model.dto.response.MedicalRecordResponse;
import backend.model.dto.response.RelativeHealthHistoryResponse;
import backend.model.dto.response.RelativeProfileDetailResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import backend.service.mapper.MedicalRecordMapper;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.util.StringUtils;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@Transactional
public class RecordService {
    private final MedicalRecordRepository medicalRecordRepository;
    private final RelativeRepository relativeRepository;
    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;
    private final MedicalRecordMapper medicalRecordMapper;
    private final CloudinaryService cloudinaryService;

    public RecordService(MedicalRecordRepository medicalRecordRepository,
            RelativeRepository relativeRepository,
            ProfileRepository profileRepository,
            UserRepository userRepository,
            MedicalRecordMapper medicalRecordMapper,
            CloudinaryService cloudinaryService) {
        this.medicalRecordRepository = medicalRecordRepository;
        this.relativeRepository = relativeRepository;
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
        this.medicalRecordMapper = medicalRecordMapper;
        this.cloudinaryService = cloudinaryService;
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
        Relative relative = getOwnedRelative(userId, profileId);

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

    public RelativeProfileDetailResponse getRelativeProfileDetail(UUID userId, UUID profileId) {
        Relative relative = getOwnedRelative(userId, profileId);
        return mapToRelativeProfileDetail(relative);
    }

    public RelativeProfileDetailResponse updateRelativeProfile(
            UUID userId,
            UUID profileId,
            UpdateRelativeProfileRequest request) {
        Relative relative = getOwnedRelative(userId, profileId);
        Profile profile = relative.getProfile();
        if (profile == null) {
            throw new ResourceNotFoundException("Không tìm thấy hồ sơ người thân");
        }

        profile.setFullname(trimToNull(request.fullName()));
        profile.setNickname(trimToNull(request.nickname()));
        profile.setGender(normalizeGender(request.gender()));
        profile.setDateOfBirth(normalizeDate(request.dateOfBirth()));
        profile.setAddress(trimToNull(request.address()));
        profile.setAllergy(trimToNull(request.allergy()));
        profile.setChronicDisease(trimToNull(request.chronicDisease()));
        profile.setClinicalNotes(trimToNull(request.clinicalNotes()));
        profile.setBloodGroup(trimToNull(request.bloodGroup()));

        profileRepository.save(profile);
        return mapToRelativeProfileDetail(relative);
    }

    public RelativeProfileDetailResponse updateRelativeAvatar(
            UUID userId,
            UUID profileId,
            MultipartFile avatarFile) {
        Relative relative = getOwnedRelative(userId, profileId);
        Profile profile = relative.getProfile();
        if (profile == null) {
            throw new ResourceNotFoundException("Không tìm thấy hồ sơ người thân");
        }

        String avatarUrl = cloudinaryService.uploadImage(avatarFile);
        profile.setAvatarUrl(avatarUrl);
        profileRepository.save(profile);

        return mapToRelativeProfileDetail(relative);
    }

    private Relative getOwnedRelative(UUID userId, UUID profileId) {
        List<Relative> candidates = relativeRepository.findAllByUserIdAndProfileId(userId, profileId);
        if (candidates.isEmpty()) {
            throw new ResourceNotFoundException("Không tìm thấy hồ sơ người thân");
        }

        for (Relative candidate : candidates) {
            String relationship = candidate.getRelationship();
            if (!"ME".equalsIgnoreCase(relationship != null ? relationship.trim() : "")) {
                return candidate;
            }
        }

        return candidates.get(0);
    }

    private RelativeProfileDetailResponse mapToRelativeProfileDetail(Relative relative) {
        Profile profile = relative.getProfile();
        if (profile == null) {
            throw new ResourceNotFoundException("Không tìm thấy hồ sơ người thân");
        }

        return RelativeProfileDetailResponse.builder()
                .profileId(profile.getId())
                .relativeId(relative.getId())
                .relativeName(profile.getFullname())
                .relationship(relative.getRelationship())
                .avatarUrl(profile.getAvatarUrl())
                .fullName(profile.getFullname())
                .nickname(profile.getNickname())
                .identityNumber(profile.getIdentityNumber())
                .gender(profile.getGender())
                .dateOfBirth(profile.getDateOfBirth())
                .phoneNumber(profile.getPhoneNumber())
                .address(profile.getAddress())
                .allergy(profile.getAllergy())
                .chronicDisease(profile.getChronicDisease())
                .clinicalNotes(profile.getClinicalNotes())
                .bloodGroup(profile.getBloodGroup())
                .build();
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

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeIdentity(String value) {
        String trimmed = trimToNull(value);
        if (trimmed == null) {
            return null;
        }
        return trimmed.replaceAll("\\s+", "");
    }

    private String normalizePhone(String value) {
        String trimmed = trimToNull(value);
        if (trimmed == null) {
            return null;
        }

        String normalized = trimmed.replaceAll("\\s+", "");
        if (normalized.startsWith("+84")) {
            normalized = "0" + normalized.substring(3);
        }
        return normalized;
    }

    private String normalizeGender(String value) {
        String trimmed = trimToNull(value);
        if (!StringUtils.hasText(trimmed)) {
            return null;
        }

        String normalized = trimmed.toLowerCase();
        return switch (normalized) {
            case "male", "m", "nam" -> "Nam";
            case "female", "f", "nu", "nữ" -> "Nữ";
            default -> trimmed;
        };
    }

    private String normalizeDate(String value) {
        String trimmed = trimToNull(value);
        if (!StringUtils.hasText(trimmed)) {
            return null;
        }

        String isoPattern = "^\\d{4}-\\d{2}-\\d{2}$";
        if (trimmed.matches(isoPattern)) {
            return trimmed;
        }

        String slashPattern = "^\\d{2}/\\d{2}/\\d{4}$";
        if (trimmed.matches(slashPattern)) {
            String[] parts = trimmed.split("/");
            return parts[2] + "-" + parts[1] + "-" + parts[0];
        }

        return trimmed;
    }

}
