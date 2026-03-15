package backend.service;

import backend.exception.InvalidRequestException;
import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.Profile;
import backend.model.Relative;
import backend.model.User;
import backend.model.dto.request.ChangePasswordRequest;
import backend.model.dto.request.UpdateMyProfileRequest;
import backend.model.dto.request.VerifyOtpRequest;
import backend.model.dto.response.PatientDetailResponse;
import backend.model.dto.response.PatientRelativeRecordResponse;
import backend.model.dto.response.RecordResponse;
import backend.model.dto.response.UserResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final RelativeRepository relativeRepository;
    private final MedicalRecordRepository medicalRecordRepository;
        private final ProfileRepository profileRepository;
        private final PasswordEncoder passwordEncoder;
        private final StringRedisTemplate stringRedisTemplate;
        private final EmailService emailService;

    public UserService(UserRepository userRepository,
                       RelativeRepository relativeRepository,
                                           MedicalRecordRepository medicalRecordRepository,
                                           ProfileRepository profileRepository,
                                           PasswordEncoder passwordEncoder,
                                           StringRedisTemplate stringRedisTemplate,
                                           EmailService emailService) {
        this.userRepository = userRepository;
        this.relativeRepository = relativeRepository;
        this.medicalRecordRepository = medicalRecordRepository;
                this.profileRepository = profileRepository;
                this.passwordEncoder = passwordEncoder;
                this.stringRedisTemplate = stringRedisTemplate;
                this.emailService = emailService;
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

        @Transactional(readOnly = true)
        public UserResponse getCurrentUser(UUID userId) {
                User user = userRepository.findById(userId)
                                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));
                return mapToUserResponse(user);
        }

        @Transactional
        public UserResponse updateCurrentUser(UUID userId, UpdateMyProfileRequest request) {
                User user = userRepository.findById(userId)
                                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));

                if (request.email() != null && !request.email().isBlank()) {
                        String normalizedEmail = request.email().trim();
                        User existedUserByEmail = userRepository.findByEmail(normalizedEmail);
                        if (existedUserByEmail != null && !existedUserByEmail.getId().equals(userId)) {
                                throw new InvalidRequestException("EMAIL_DUPLICATE", "Email already exists");
                        }
                        user.setEmail(normalizedEmail);
                }

                if (request.phoneNumber() != null && !request.phoneNumber().isBlank()) {
                        String normalizedPhone = request.phoneNumber().trim();
                        User existedUserByPhone = userRepository.findByPhoneNumber(normalizedPhone);
                        if (existedUserByPhone != null && !existedUserByPhone.getId().equals(userId)) {
                                throw new InvalidRequestException("PHONE_DUPLICATE", "Phone number already exists");
                        }
                        user.setPhoneNumber(normalizedPhone);
                }

                Profile profile = user.getProfile();
                if (profile == null) {
                        profile = new Profile();
                        user.setProfile(profile);
                }

                if (request.fullName() != null && !request.fullName().isBlank()) {
                        profile.setFullname(request.fullName().trim());
                }
                if (request.gender() != null && !request.gender().isBlank()) {
                        profile.setGender(request.gender().trim());
                }
                if (request.dateOfBirth() != null && !request.dateOfBirth().isBlank()) {
                        profile.setDateOfBirth(request.dateOfBirth().trim());
                }
                if (request.address() != null && !request.address().isBlank()) {
                        profile.setAddress(request.address().trim());
                }
                if (request.avatarUrl() != null && !request.avatarUrl().isBlank()) {
                        profile.setAvatarUrl(request.avatarUrl().trim());
                }

                Profile savedProfile = profileRepository.save(profile);
                user.setProfile(savedProfile);
                User savedUser = userRepository.save(user);
                return mapToUserResponse(savedUser);
        }

        @Transactional
        public Map<String, String> updateMyPassword(UUID userId, ChangePasswordRequest request) {
                User user = userRepository.findById(userId)
                                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));

                String otpKey = buildOtpKey(userId);
                String incomingOtp = request.otp() == null ? "" : request.otp().trim();

                if (incomingOtp.isBlank()) {
                        if (user.getEmail() == null || user.getEmail().isBlank()) {
                                throw new InvalidRequestException("EMAIL_REQUIRED", "Cannot send OTP because account email is empty");
                        }
                        String otp = generateOtp();
                        stringRedisTemplate.opsForValue().set(
                                        otpKey,
                                        passwordEncoder.encode(otp),
                                        Duration.ofMinutes(5)
                        );
                        emailService.sendPasswordOtp(user.getEmail(), otp);
                        return Map.of("message", "OTP has been sent to your email");
                }

                if (request.newPassword() == null || request.newPassword().isBlank()) {
                        throw new InvalidRequestException("NEW_PASSWORD_REQUIRED", "New password is required when OTP is provided");
                }
                String normalizedNewPassword = request.newPassword().trim();
                if (normalizedNewPassword.length() < 6 || normalizedNewPassword.length() > 20) {
                        throw new InvalidRequestException("PASSWORD_INVALID", "Password must be between 6 and 20 characters");
                }

                String otpHash = stringRedisTemplate.opsForValue().get(otpKey);
                if (otpHash == null) {
                        throw new InvalidRequestException("OTP_EXPIRED", "OTP is invalid or expired. Please request a new OTP");
                }
                if (!passwordEncoder.matches(incomingOtp, otpHash)) {
                        throw new InvalidRequestException("OTP_INVALID", "OTP is invalid");
                }
                if (passwordEncoder.matches(normalizedNewPassword, user.getPassword())) {
                        throw new InvalidRequestException("PASSWORD_NOT_CHANGED", "New password must be different from current password");
                }

                user.setPassword(passwordEncoder.encode(normalizedNewPassword));
                userRepository.save(user);
                stringRedisTemplate.delete(otpKey);

                return Map.of("message", "Password updated successfully");
        }

        @Transactional(readOnly = true)
        public Map<String, String> verifyMyPasswordOtp(UUID userId, VerifyOtpRequest request) {
                User user = userRepository.findById(userId)
                                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));

                String incomingOtp = request.otp() == null ? "" : request.otp().trim();
                if (incomingOtp.isBlank()) {
                        throw new InvalidRequestException("OTP_REQUIRED", "OTP is required");
                }

                String otpHash = stringRedisTemplate.opsForValue().get(buildOtpKey(user.getId()));
                if (otpHash == null) {
                        throw new InvalidRequestException("OTP_EXPIRED", "OTP is invalid or expired. Please request a new OTP");
                }
                if (!passwordEncoder.matches(incomingOtp, otpHash)) {
                        throw new InvalidRequestException("OTP_INVALID", "OTP is invalid");
                }

                return Map.of("message", "OTP verified successfully");
        }

        private String buildOtpKey(UUID userId) {
                return "user:password:otp:" + userId;
        }

        private String generateOtp() {
                int code = new Random().nextInt(900000) + 100000;
                return String.valueOf(code);
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