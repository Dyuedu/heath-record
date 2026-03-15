package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.Profile;
import backend.model.Relative;
import backend.model.User;
import backend.model.dto.response.PatientDetailResponse;
import backend.model.dto.response.PatientRelativeRecordResponse;
import backend.model.dto.response.RecordResponse;
import backend.model.dto.response.UserResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final RelativeRepository relativeRepository;
    private final MedicalRecordRepository medicalRecordRepository;

    public UserService(UserRepository userRepository,
                       RelativeRepository relativeRepository,
                       MedicalRecordRepository medicalRecordRepository) {
        this.userRepository = userRepository;
        this.relativeRepository = relativeRepository;
        this.medicalRecordRepository = medicalRecordRepository;
    }

    @Transactional(readOnly = true)
    public List<UserResponse> searchPatients(String phone) {
        return userRepository.findByPhoneNumberContaining(phone)
                .stream()
                .map(this::mapToUserResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public PatientDetailResponse getPatientDetail(UUID patientId) {
        // 1. Tìm User (Chủ tài khoản)
        User patient = userRepository.findById(patientId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bệnh nhân"));

        // 2. Lấy danh sách Relatives (Bao gồm cả bản ghi "Me" và người thân)
        List<PatientRelativeRecordResponse> relatives = relativeRepository.findByUserId(patientId)
                .stream()
                .map(relative -> {
                    // Lấy profile của người thân/bản thân để có thông tin chi tiết
                    Profile relProfile = relative.getProfile();

                    return PatientRelativeRecordResponse.builder()
                            .id(relative.getId())
                            // Lấy tên từ Profile thay vì bảng Relative trực tiếp
                            .name(relProfile != null ? relProfile.getFullname() : "N/A")
                            .relationship(relative.getRelationship())
                            .records(
                                    medicalRecordRepository.findByRelativeId(relative.getId())
                                            .stream()
                                            .map(this::mapToRecordResponse)
                                            .toList()
                            )
                            .build();
                })
                .toList();

        return PatientDetailResponse.builder()
                .patient(mapToUserResponse(patient))
                .relatives(relatives)
                .build();
    }

    private UserResponse mapToUserResponse(User user) {
        // Lấy profile từ User
        Profile profile = user.getProfile();

        return UserResponse.builder()
                .id(user.getId())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .role(user.getRole() != null ? user.getRole().getName() : "user")
                // Các thông tin nhân khẩu học lấy từ Profile object
                .fullName(profile != null ? profile.getFullname() : "N/A")
                .gender(profile != null ? profile.getGender() : null)
                .dateOfBirth(profile != null ? profile.getDateOfBirth() : null)
                .address(profile != null ? profile.getAddress() : null)
                .avatarUrl(profile != null ? profile.getAvatarUrl() : null)
                .build();
    }

    private RecordResponse mapToRecordResponse(MedicalRecord record) {
        // Lấy tên hiển thị từ Profile của Relative gắn với Record đó
        String displayName = "N/A";
        if (record.getRelative() != null && record.getRelative().getProfile() != null) {
            displayName = record.getRelative().getProfile().getFullname();
        }

        return RecordResponse.builder()
                .id(record.getId())
                .title(record.getTitle())
                .type(record.getType()) // Đã thêm trường type như thảo luận trước
                .notes(record.getNotes())
                .important(record.isImportant())
                .tags(record.getTags() != null ? List.copyOf(record.getTags()) : List.of())
                .attachments(record.getAttachments() != null ? List.copyOf(record.getAttachments()) : List.of())
                .createdAt(record.getCreatedAt())
                .relativeId(record.getRelative().getId())
                .relativeName(displayName)
                .build();
    }
}