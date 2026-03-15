package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.Profile;
import backend.model.User;
import backend.model.dto.response.PatientDetailResponse;
import backend.model.dto.response.RelativeHealthHistoryResponse;
import backend.model.dto.response.UserResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import backend.service.mapper.MedicalRecordMapper;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {
    private final UserRepository userRepository;
        private final RelativeRepository relativeRepository;
        private final MedicalRecordRepository medicalRecordRepository;
        private final MedicalRecordMapper medicalRecordMapper;

    public UserService(UserRepository userRepository,
                                           RelativeRepository relativeRepository,
                                           MedicalRecordRepository medicalRecordRepository,
                                           MedicalRecordMapper medicalRecordMapper) {
        this.userRepository = userRepository;
        this.relativeRepository = relativeRepository;
        this.medicalRecordRepository = medicalRecordRepository;
                this.medicalRecordMapper = medicalRecordMapper;
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
        List<RelativeHealthHistoryResponse> relatives = relativeRepository.findByUserId(patientId)
                .stream()
                .map(relative -> medicalRecordMapper.toRelativeHistory(
                        relative,
                        medicalRecordRepository.findByRelativeId(relative.getId())
                ))
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

}