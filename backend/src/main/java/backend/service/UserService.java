package backend.service;

import backend.exception.InvalidRequestException;
import backend.exception.PhoneDuplicateException;
import backend.exception.ResourceNotFoundException;
import backend.model.Profile;
import backend.model.User;
import backend.model.dto.request.ChangePasswordRequest;
import backend.model.dto.request.UpdateMyProfileRequest;
import backend.model.dto.response.PatientDetailResponse;
import backend.model.dto.response.RelativeHealthHistoryResponse;
import backend.model.dto.response.UserResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import backend.service.mapper.MedicalRecordMapper;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final RelativeRepository relativeRepository;
    private final MedicalRecordRepository medicalRecordRepository;
    private final MedicalRecordMapper medicalRecordMapper;
    private final ProfileRepository profileRepository;
    private final PasswordEncoder passwordEncoder;
    private final CloudinaryService cloudinaryService;

    private static final int MIN_PASSWORD_LENGTH = 6;
    private static final int MAX_PASSWORD_LENGTH = 64;
    private static final DateTimeFormatter DATE_SLASH_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public UserService(UserRepository userRepository,
                       RelativeRepository relativeRepository,
                       MedicalRecordRepository medicalRecordRepository,
                       MedicalRecordMapper medicalRecordMapper,
                       ProfileRepository profileRepository,
                       PasswordEncoder passwordEncoder,
                       CloudinaryService cloudinaryService) {
        this.userRepository = userRepository;
        this.relativeRepository = relativeRepository;
        this.medicalRecordRepository = medicalRecordRepository;
        this.medicalRecordMapper = medicalRecordMapper;
        this.profileRepository = profileRepository;
        this.passwordEncoder = passwordEncoder;
        this.cloudinaryService = cloudinaryService;
    }

    @Transactional(readOnly = true)
    public List<UserResponse> listDoctors(String keyword) {
        String normalized = trimToNull(keyword);
        return userRepository.findDoctors(normalized)
                .stream()
                .map(this::mapToUserResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<UserResponse> searchPatients(String keyword) {
        String normalized = trimToNull(keyword);
        if (!StringUtils.hasText(normalized)) {
            return List.of();
        }

        return userRepository.searchByPhoneOrIdentity(normalized)
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

    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(UUID userId) {
        User user = getUser(userId);
        return mapToUserResponse(user);
    }

    @Transactional
    public UserResponse updateCurrentUser(UUID userId, UpdateMyProfileRequest request) {
        User user = getUser(userId);

        String newPhone = trimToNull(request.phoneNumber());
        if (StringUtils.hasText(newPhone) && !newPhone.equals(user.getPhoneNumber())) {
            userRepository.findByPhoneNumber(newPhone)
                    .ifPresent(existing -> {
                        if (!existing.getId().equals(userId)) {
                            throw new PhoneDuplicateException(newPhone);
                        }
                    });
            user.setPhoneNumber(newPhone);
        }

        Profile profile = user.getProfile();
        if (profile == null) {
            profile = new Profile();
            profile = profileRepository.save(profile);
            user.setProfile(profile);
        }

        profile.setFullname(trimToNull(request.fullName()));
        profile.setGender(normalizeGender(request.gender()));
        profile.setDateOfBirth(normalizeDate(request.dateOfBirth()));
        profile.setAddress(trimToNull(request.address()));
        profile.setAllergy(trimToNull(request.allergy()));
        profile.setChronicDisease(trimToNull(request.chronicDisease()));
        profile.setClinicalNotes(trimToNull(request.clinicalNotes()));
        profile.setBloodGroup(trimToNull(request.bloodGroup()));

        userRepository.save(user);
        return mapToUserResponse(user);
    }

    @Transactional
    public UserResponse updateMyAvatar(UUID userId, MultipartFile avatar) {
        User user = getUser(userId);
        Profile profile = user.getProfile();
        if (profile == null) {
            profile = new Profile();
            profile = profileRepository.save(profile);
            user.setProfile(profile);
        }

        String avatarUrl = cloudinaryService.uploadAvatar(userId, avatar);
        profile.setAvatarUrl(avatarUrl);
        userRepository.save(user);
        return mapToUserResponse(user);
    }

    @Transactional
    public Map<String, String> updateMyPassword(UUID userId, ChangePasswordRequest request) {
        User user = getUser(userId);
        String oldPassword = trimToNull(request.oldPassword());
        String newPassword = trimToNull(request.newPassword());

        if (!StringUtils.hasText(oldPassword) || !StringUtils.hasText(newPassword)) {
            throw new InvalidRequestException("PASSWORD_REQUEST_INVALID", "Mật khẩu cũ và mật khẩu mới là bắt buộc");
        }

        validatePasswordStrength(newPassword);

        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new InvalidRequestException("OLD_PASSWORD_INVALID", "Mật khẩu cũ không chính xác");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        return Map.of("message", "Đổi mật khẩu thành công");
    }

    private UserResponse mapToUserResponse(User user) {
        // Lấy profile từ User
        Profile profile = user.getProfile();

        return UserResponse.builder()
                .id(user.getId())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .identityNumber(profile != null ? profile.getIdentityNumber() : null)
                .role(user.getRole() != null ? user.getRole().getName() : "user")
                // Các thông tin nhân khẩu học lấy từ Profile object
                .fullName(profile != null ? profile.getFullname() : "N/A")
                .gender(profile != null ? profile.getGender() : null)
                .dateOfBirth(profile != null ? profile.getDateOfBirth() : null)
                .address(profile != null ? profile.getAddress() : null)
                .avatarUrl(profile != null ? profile.getAvatarUrl() : null)
                .allergy(profile != null ? profile.getAllergy() : null)
                .chronicDisease(profile != null ? profile.getChronicDisease() : null)
                .clinicalNotes(profile != null ? profile.getClinicalNotes() : null)
                .bloodGroup(profile != null ? profile.getBloodGroup() : null)
                .status(user.getStatus() != null ? user.getStatus().name() : null)
                .cccdFrontUrl(profile != null ? profile.getCccdFrontUrl() : null)
                .cccdBackUrl(profile != null ? profile.getCccdBackUrl() : null)
                .diplomaUrl(profile != null ? profile.getDiplomaUrl() : null)
                .createdAt(user.getCreatedAt())
                .build();
    }

    private User getUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));
    }

    private void validatePasswordStrength(String newPassword) {
        if (!StringUtils.hasText(newPassword)
                || newPassword.length() < MIN_PASSWORD_LENGTH
                || newPassword.length() > MAX_PASSWORD_LENGTH) {
            throw new InvalidRequestException(
                    "PASSWORD_INVALID",
                    "Mật khẩu mới phải có độ dài từ " + MIN_PASSWORD_LENGTH + " đến " + MAX_PASSWORD_LENGTH + " ký tự"
            );
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeGender(String value) {
        String normalized = trimToNull(value);
        if (normalized == null) {
            return null;
        }

        String key = normalized.toLowerCase();
        if ("nam".equals(key)) {
            return "Nam";
        }
        if ("nữ".equals(key) || "nu".equals(key)) {
            return "Nữ";
        }

        throw new InvalidRequestException("GENDER_INVALID", "Giới tính chỉ chấp nhận Nam hoặc Nữ");
    }

    private String normalizeDate(String value) {
        String normalized = trimToNull(value);
        if (normalized == null) {
            return null;
        }

        try {
            LocalDate isoDate = LocalDate.parse(normalized);
            return isoDate.toString();
        } catch (DateTimeParseException ignored) {
            // Try dd/MM/yyyy next.
        }

        try {
            LocalDate slashDate = LocalDate.parse(normalized, DATE_SLASH_FORMATTER);
            return slashDate.toString();
        } catch (DateTimeParseException ignored) {
            throw new InvalidRequestException("DATE_OF_BIRTH_INVALID", "Ngày sinh không hợp lệ");
        }
    }
}
