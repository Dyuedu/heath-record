package backend.service;

import backend.exception.EmailDuplicateException;
import backend.exception.InvalidRequestException;
import backend.exception.PhoneDuplicateException;
import backend.exception.ResourceNotFoundException;
import backend.model.Profile;
import backend.model.Role;
import backend.model.User;
import backend.model.dto.request.AdminUserRequest;
import backend.model.dto.response.UserResponse;
import backend.model.UserStatus;
import backend.repository.MedicalRecordRepository;
import backend.repository.ProfileRepository;
import backend.repository.RoleRepository;
import backend.repository.UserRepository;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.time.Duration;
import java.time.LocalDateTime;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class AdminUserService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final RoleRepository roleRepository;
    private final MedicalRecordRepository medicalRecordRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final RedisTemplate<String, String> redisTemplate;
    private final String doctorActivationLinkTemplate;

    private static final String DOCTOR_ACTIVATION_KEY_PREFIX = "doctor:activation:";
    private static final Duration DOCTOR_ACTIVATION_TTL = Duration.ofHours(24);

    public AdminUserService(UserRepository userRepository,
                            ProfileRepository profileRepository,
                            RoleRepository roleRepository,
                            MedicalRecordRepository medicalRecordRepository,
                            PasswordEncoder passwordEncoder,
                            EmailService emailService,
                            @Qualifier("redisTemplate") RedisTemplate<String, String> redisTemplate,
                            @Value("${app.doctor.activation-link-template:http://localhost:8081/api/auth/activate-doctor?token={token}}")
                            String doctorActivationLinkTemplate) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.roleRepository = roleRepository;
        this.medicalRecordRepository = medicalRecordRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        this.redisTemplate = redisTemplate;
        this.doctorActivationLinkTemplate = doctorActivationLinkTemplate;
    }

    @Transactional(readOnly = true)
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(this::mapToUserResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getDashboardStats() {
        long totalUsers = userRepository.count();
        long pendingApprovals = userRepository.countByStatus(UserStatus.PENDING);
        
        LocalDateTime startOfMonth = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0);
        long newRecordsThisMonth = medicalRecordRepository.countByDatetimeStartAfter(startOfMonth);

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", totalUsers);
        stats.put("pendingApprovals", pendingApprovals);
        stats.put("newRecordsThisMonth", newRecordsThisMonth);
        return stats;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getRecordStats(String period) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime start;

        String normalizedPeriod = (period == null || period.isBlank()) ? "month" : period.trim().toLowerCase();

        switch (normalizedPeriod) {
            case "day"  -> start = now.minusDays(13).toLocalDate().atStartOfDay();  // 14 days
            case "week" -> start = now.minusWeeks(7).toLocalDate().atStartOfDay();  // 8 weeks
            case "year" -> start = now.minusYears(4).withMonth(1).withDayOfMonth(1).toLocalDate().atStartOfDay(); // 5 years
            default     -> { normalizedPeriod = "month"; start = now.minusMonths(11).withDayOfMonth(1).toLocalDate().atStartOfDay(); } // 12 months
        }

        long totalRecords = medicalRecordRepository.countByDatetimeStartBetween(start, now);
        long totalUsers   = userRepository.count();

        List<Object[]> recordRows = medicalRecordRepository.countGroupedByPeriod(normalizedPeriod, start, now);
        List<Map<String, Object>> recordChartData = new ArrayList<>();
        for (Object[] row : recordRows) {
            Map<String, Object> point = new HashMap<>();
            point.put("label", row[0] != null ? row[0].toString() : "");
            point.put("count", ((Number) row[1]).longValue());
            recordChartData.add(point);
        }

        List<Object[]> userRows = userRepository.countUsersGroupedByPeriod(normalizedPeriod, start, now);
        List<Map<String, Object>> userChartData = new ArrayList<>();
        for (Object[] row : userRows) {
            Map<String, Object> point = new HashMap<>();
            point.put("label", row[0] != null ? row[0].toString() : "");
            point.put("count", ((Number) row[1]).longValue());
            userChartData.add(point);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("totalRecords", totalRecords);
        result.put("totalUsers", totalUsers);
        result.put("chartData", recordChartData); // Keep for backwards compatibility/dashboard
        result.put("recordChartData", recordChartData);
        result.put("userChartData", userChartData);
        return result;
    }

    @Transactional(readOnly = true)
    public List<UserResponse> searchUsers(String search, String role, String status) {
        String searchParam = StringUtils.hasText(search) ? search.trim() : null;
        String roleParam = StringUtils.hasText(role) && !role.equalsIgnoreCase("Tất cả") ? role.trim() : null;
        String statusParam = StringUtils.hasText(status) ? status.trim() : null;
        
        return userRepository.searchUsers(searchParam, roleParam, statusParam)
                .stream()
                .map(this::mapToUserResponse)
                .toList();
    }

    @Transactional
    public UserResponse createUser(AdminUserRequest request) {
        String email = trimToNull(request.email());
        validateEmail(email, null);

        String rawPassword = trimToNull(request.password());
        if (!StringUtils.hasText(rawPassword)) {
            throw new InvalidRequestException("PASSWORD_REQUIRED", "Mật khẩu là bắt buộc khi tạo người dùng mới");
        }

        Role role = resolveRole(request.role());

        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(rawPassword));
        user.setRole(role);
        boolean doctorRole = isDoctorRole(role);
        user.setStatus(resolveInitialStatus(request.status(), doctorRole));
        user.setCreatedAt(LocalDateTime.now());

        if (!role.getName().equalsIgnoreCase("ROLE_ADMIN") && !role.getName().equalsIgnoreCase("ADMIN")) {
            String phone = trimToNull(request.phoneNumber());
            validatePhone(phone, null);
            user.setPhoneNumber(phone);
            
            Profile profile = new Profile();
            applyProfile(profile, request);
            profile = profileRepository.save(profile);
            user.setProfile(profile);
        }

        User saved = userRepository.save(user);
        if (doctorRole) {
            sendDoctorActivationEmail(saved);
        }
        return mapToUserResponse(saved);
    }

    @Transactional
    public void activateDoctorAccount(String token) {
        String normalizedToken = trimToNull(token);
        if (!StringUtils.hasText(normalizedToken)) {
            throw new InvalidRequestException("ACTIVATION_TOKEN_REQUIRED", "Thiếu token kích hoạt");
        }

        String key = buildDoctorActivationKey(normalizedToken);
        String userIdRaw = redisTemplate.opsForValue().get(key);
        if (!StringUtils.hasText(userIdRaw)) {
            throw new InvalidRequestException("ACTIVATION_TOKEN_INVALID", "Liên kết kích hoạt không hợp lệ hoặc đã hết hạn");
        }

        UUID userId;
        try {
            userId = UUID.fromString(userIdRaw);
        } catch (IllegalArgumentException ex) {
            redisTemplate.delete(key);
            throw new InvalidRequestException("ACTIVATION_TOKEN_INVALID", "Liên kết kích hoạt không hợp lệ");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản cần kích hoạt"));

        if (!isDoctorRole(user.getRole())) {
            throw new InvalidRequestException("ACTIVATION_NOT_ALLOWED", "Chỉ tài khoản bác sĩ mới dùng liên kết kích hoạt này");
        }

        user.setStatus(UserStatus.ACTIVE);
        userRepository.save(user);
        redisTemplate.delete(key);
    }

    @Transactional
    public UserResponse updateUser(UUID userId, AdminUserRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        String email = trimToNull(request.email());
        validateEmail(email, user.getId());

        user.setEmail(email);

        String newPassword = trimToNull(request.password());
        if (StringUtils.hasText(newPassword)) {
            user.setPassword(passwordEncoder.encode(newPassword));
        }

        Role role = resolveRole(request.role());
        user.setRole(role);

        if (!role.getName().equalsIgnoreCase("ROLE_ADMIN") && !role.getName().equalsIgnoreCase("ADMIN")) {
            String phone = trimToNull(request.phoneNumber());
            validatePhone(phone, user.getId());
            user.setPhoneNumber(phone);

            Profile profile = user.getProfile();
            if (profile == null) {
                profile = new Profile();
            }
            applyProfile(profile, request);
            profile = profileRepository.save(profile);
            user.setProfile(profile);
        }
        
        if (StringUtils.hasText(request.status())) {
            user.setStatus(UserStatus.valueOf(request.status()));
        }

        User saved = userRepository.save(user);
        return mapToUserResponse(saved);
    }

    @Transactional
    public UserResponse changeUserStatus(UUID userId, String newStatus) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));
        
        user.setStatus(UserStatus.valueOf(newStatus));
        User saved = userRepository.save(user);
        return mapToUserResponse(saved);
    }

    private void validateEmail(String email, UUID currentUserId) {
        if (!StringUtils.hasText(email)) {
            throw new InvalidRequestException("EMAIL_REQUIRED", "Email là bắt buộc");
        }
        userRepository.findByEmail(email)
                .ifPresent(existing -> {
                    if (currentUserId == null || !existing.getId().equals(currentUserId)) {
                        throw new EmailDuplicateException(email);
                    }
                });
    }

    private void validatePhone(String phone, UUID currentUserId) {
        if (!StringUtils.hasText(phone)) {
            throw new InvalidRequestException("PHONE_REQUIRED", "Số điện thoại là bắt buộc");
        }
        userRepository.findByPhoneNumber(phone)
                .ifPresent(existing -> {
                    if (currentUserId == null || !existing.getId().equals(currentUserId)) {
                        throw new PhoneDuplicateException(phone);
                    }
                });
    }

    private void applyProfile(Profile profile, AdminUserRequest request) {
        profile.setFullname(trimToNull(request.fullName()));
        profile.setIdentityNumber(trimToNull(request.identityNumber()));
        profile.setGender(trimToNull(request.gender()));
        profile.setDateOfBirth(trimToNull(request.dateOfBirth()));
        profile.setAddress(trimToNull(request.address()));
        profile.setPhoneNumber(trimToNull(request.phoneNumber()));
    }

    private Role resolveRole(String roleInput) {
        String normalized = trimToNull(roleInput);
        if (!StringUtils.hasText(normalized)) {
            throw new InvalidRequestException("ROLE_REQUIRED", "Vai trò là bắt buộc");
        }

        Role role = findRoleCandidate(normalized);
        if (role == null) {
            throw new ResourceNotFoundException("Không tìm thấy vai trò " + normalized);
        }
        return role;
    }

    private Role findRoleCandidate(String rawRole) {
        String candidate = rawRole.trim();
        Role role = roleRepository.findByName(candidate);
        if (role != null) {
            return role;
        }

        role = roleRepository.findByName(candidate.toLowerCase(Locale.ROOT));
        if (role != null) {
            return role;
        }

        role = roleRepository.findByName(candidate.toUpperCase(Locale.ROOT));
        if (role != null) {
            return role;
        }

        if (candidate.toUpperCase(Locale.ROOT).startsWith("ROLE_")) {
            String withoutPrefix = candidate.substring(5);
            role = roleRepository.findByName(withoutPrefix);
            if (role != null) {
                return role;
            }
            return roleRepository.findByName(withoutPrefix.toLowerCase(Locale.ROOT));
        }

        String prefixedUpper = "ROLE_" + candidate.toUpperCase(Locale.ROOT);
        role = roleRepository.findByName(prefixedUpper);
        if (role != null) {
            return role;
        }
        return roleRepository.findByName(("role_" + candidate.toLowerCase(Locale.ROOT)));
    }

    private UserStatus resolveInitialStatus(String statusInput, boolean doctorRole) {
        if (doctorRole) {
            return UserStatus.PENDING;
        }
        return StringUtils.hasText(statusInput) ? UserStatus.valueOf(statusInput) : UserStatus.ACTIVE;
    }

    private boolean isDoctorRole(Role role) {
        if (role == null || !StringUtils.hasText(role.getName())) {
            return false;
        }
        String normalizedRole = role.getName().trim().toUpperCase(Locale.ROOT);
        return normalizedRole.equals("DOCTOR") || normalizedRole.equals("ROLE_DOCTOR");
    }

    private void sendDoctorActivationEmail(User user) {
        String token = UUID.randomUUID().toString();
        redisTemplate.opsForValue().set(buildDoctorActivationKey(token), user.getId().toString(), DOCTOR_ACTIVATION_TTL);
        String activationLink = doctorActivationLinkTemplate.replace("{token}", token);
        emailService.sendDoctorActivationEmail(user.getEmail(), activationLink);
    }

    private String buildDoctorActivationKey(String token) {
        return DOCTOR_ACTIVATION_KEY_PREFIX + token;
    }

    private UserResponse mapToUserResponse(User user) {
        Profile profile = user.getProfile();
        return UserResponse.builder()
                .id(user.getId())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .role(user.getRole() != null ? user.getRole().getName() : null)
                .fullName(profile != null ? profile.getFullname() : null)
                .gender(profile != null ? profile.getGender() : null)
                .dateOfBirth(profile != null ? profile.getDateOfBirth() : null)
                .address(profile != null ? profile.getAddress() : null)
                .department(profile != null ? profile.getDepartment() : null)
                .avatarUrl(profile != null ? profile.getAvatarUrl() : null)
                .cccdFrontUrl(profile != null ? profile.getCccdFrontUrl() : null)
                .cccdBackUrl(profile != null ? profile.getCccdBackUrl() : null)
                .diplomaUrl(profile != null ? profile.getDiplomaUrl() : null)
                .status(user.getStatus() != null ? user.getStatus().name() : null)
                .createdAt(user.getCreatedAt())
                .build();
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
