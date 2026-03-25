package backend.service;

import backend.exception.EmailDuplicateException;
import backend.exception.IdentityDuplicateException;
import backend.exception.InvalidRequestException;
import backend.exception.MultipleResourceDuplicateException;
import backend.exception.PhoneDuplicateException;
import backend.exception.ResourceDuplicateException;
import backend.model.*;
import backend.model.dto.request.LoginRequest;
import backend.model.dto.request.RegisterRequest;
import backend.model.dto.response.RegisterResultResponse;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.RoleRepository;
import backend.repository.UserRepository;
import backend.model.UserStatus;
import java.security.SecureRandom;
import java.time.Duration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

@Service
public class AuthService {
    @Value("${app.feature.enableProfileLinkApproval:true}")
    private boolean enableProfileLinkApproval;

    private final PasswordEncoder passwordEncoder;
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final RelativeRepository relativeRepository;
    private final LinkRequestService linkRequestService;
    private final JWTService jwtService;
    private final AuthenticationManager authenticationManager;
    private final EmailService emailService;
    private final RedisTemplate<String, String> redisTemplate;

    private static final String FORGOT_PASSWORD_OTP_KEY_PREFIX = "auth:forgot-password:otp:";
    private static final Duration FORGOT_PASSWORD_OTP_TTL = Duration.ofMinutes(5);
    private static final Pattern OTP_PATTERN = Pattern.compile("\\d{6}");
    private static final SecureRandom OTP_RANDOM = new SecureRandom();
    private static final int MIN_PASSWORD_LENGTH = 6;
    private static final int MAX_PASSWORD_LENGTH = 64;

    public AuthService(PasswordEncoder passwordEncoder, RoleRepository roleRepository, UserRepository userRepository,
            ProfileRepository profileRepository, RelativeRepository relativeRepository,
            LinkRequestService linkRequestService, JWTService jwtService,
            AuthenticationManager authenticationManager, EmailService emailService,
            @Qualifier("redisTemplate") RedisTemplate<String, String> redisTemplate) {
        this.passwordEncoder = passwordEncoder;
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.relativeRepository = relativeRepository;
        this.linkRequestService = linkRequestService;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.emailService = emailService;
        this.redisTemplate = redisTemplate;
    }

    @Transactional
    public RegisterResultResponse register(RegisterRequest registerRequest) {
        String normalizedIdentity = normalizeIdentity(registerRequest.identityNumber());
        String normalizedPhone = normalizePhone(registerRequest.phone());

        List<User> usersByEmail = userRepository.findAllByEmail(registerRequest.email());
        List<User> usersByPhone = normalizedPhone != null
                ? userRepository.findAllByPhoneNumber(normalizedPhone)
                : List.of();
        Profile duplicated = null;
        if (enableProfileLinkApproval) {
            duplicated = linkRequestService.detectDuplicateProfile(
                normalizedIdentity,
                normalizedPhone
            ).orElse(null);
        }

        Profile existingByIdentity = normalizedIdentity != null
                ? profileRepository.findFirstByIdentityNumber(normalizedIdentity).orElse(null)
                : null;
        User pendingUser = resolvePendingReRegistrationCandidate(usersByEmail, usersByPhone);

        List<ResourceDuplicateException> errors = new ArrayList<>();
        if (hasDuplicateConflict(usersByEmail, pendingUser)) {
            errors.add(new EmailDuplicateException(registerRequest.email()));
        }
        boolean hasPhoneConflict = hasDuplicateConflict(usersByPhone, pendingUser);
        if (hasPhoneConflict && !isPhoneConflictAllowedForLinkRequest(usersByPhone, pendingUser, duplicated)) {
            errors.add(new PhoneDuplicateException(registerRequest.phone()));
        }
        boolean isIdentityConflict = existingByIdentity != null && !isSameProfileOfUser(existingByIdentity, pendingUser);
        if (isIdentityConflict && duplicated == null) {
            errors.add(new IdentityDuplicateException(registerRequest.identityNumber()));
        }
        if (!errors.isEmpty()) {
            throw new MultipleResourceDuplicateException(errors);
        }

        Role role = resolveSignupRole(registerRequest.role());

        if (pendingUser != null) {
            refreshPendingUserRegistration(pendingUser, registerRequest, role, normalizedIdentity, normalizedPhone);
            return RegisterResultResponse.builder()
                    .status("REGISTERED")
                    .requestId(null)
                    .message("Tài khoản đang chờ xác thực đã được cập nhật. Vui lòng kiểm tra email để nhận mã OTP mới.")
                    .build();
        }

        boolean confirmLink = Boolean.TRUE.equals(registerRequest.confirmLinkRequest());
        if (duplicated != null && !confirmLink) {
            return RegisterResultResponse.builder()
                .status("PROFILE_EXISTS_CONFIRM_REQUIRED")
                .requestId(null)
                .message("Thông tin người dùng này đã tồn tại, bạn có muốn gửi yêu cầu liên kết thông tin?")
                .build();
        }


        User user = new User();
        user.setEmail(registerRequest.email());
        user.setPhoneNumber(normalizedPhone);
        user.setPassword(passwordEncoder.encode(registerRequest.password()));
        user.setRole(role);
        
        String otp = generateOtp();
        user.setOtpCode(otp);
        user.setOtpExpiryTime(java.time.LocalDateTime.now().plusMinutes(1));
        user.setStatus(UserStatus.PENDING);

        User savedUser = userRepository.save(user);

        if (duplicated != null) {
            ProfileLinkRequest linkRequest = linkRequestService.createLinkRequest(
                savedUser,
                duplicated,
                RequestType.REGISTER_LINK,
                null,
                "Yêu cầu liên kết hồ sơ khi đăng ký"
            );

            return RegisterResultResponse.builder()
                .status("LINK_REQUEST_CREATED")
                .requestId(linkRequest.getId())
                .message("Tài khoản đã được tạo, yêu cầu liên kết hồ sơ đang chờ phê duyệt")
                .build();
        }

        Profile profile = new Profile();
        profile.setFullname(registerRequest.fullname());
        profile.setIdentityNumber(normalizedIdentity);
        profile.setPhoneNumber(normalizedPhone);
        Profile savedProfile = profileRepository.save(profile);

        savedUser.setProfile(savedProfile);
        userRepository.save(savedUser);

        Relative self = new Relative();
        self.setRelationship("Me");
        self.setUser(savedUser);
        self.setProfile(savedProfile);
        relativeRepository.save(self);

        try {
            emailService.sendRegistrationOtp(savedUser.getEmail(), otp);
        } catch (Exception e) {
            System.err.println("Info: Could not send email OTP: " + e.getMessage());
        }

        return RegisterResultResponse.builder()
            .status("REGISTERED")
            .requestId(null)
            .message("Đăng ký thành công. Vui lòng kiểm tra email để nhận mã OTP.")
            .build();
    }

    public String login(LoginRequest loginRequest) {
        return verify(loginRequest);
    }

    public String verify(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.email(), loginRequest.password()));

        if (authentication.isAuthenticated()) {
            UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
            User user = userRepository.findById(userPrincipal.getId()).orElse(null);
            
            if (user != null && user.getStatus() == UserStatus.PENDING) {
                throw new IllegalStateException("Tài khoản của bạn chưa xác thực, vui lòng xác thực tài khoản");
            }
            if (user != null && user.getStatus() == UserStatus.LOCKED) {
                throw new IllegalStateException("Tài khoản đã bị khoá, vui lòng liên hệ ban quản lý");
            }
            return jwtService.generateToken(userPrincipal);
        }
        throw new BadCredentialsException("Email hoặc mật khẩu không chính xác");
    }

    @Transactional
    public void verifyOtp(String email, String otp) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy user với email này"));
        if (user.getStatus() == UserStatus.ACTIVE) {
            throw new IllegalStateException("Tài khoản đã được xác thực");
        }
        if (user.getOtpCode() == null || !user.getOtpCode().equals(otp)) {
            throw new IllegalArgumentException("Mã OTP không chính xác");
        }
        if (user.getOtpExpiryTime() != null && user.getOtpExpiryTime().isBefore(java.time.LocalDateTime.now())) {
            throw new IllegalStateException("Mã OTP đã hết hạn");
        }
        user.setStatus(UserStatus.ACTIVE);
        user.setOtpCode(null);
        user.setOtpExpiryTime(null);
        userRepository.save(user);
    }

    @Transactional
    public void resendOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy user với email này"));
        if (user.getStatus() == UserStatus.ACTIVE) {
            throw new IllegalStateException("Tài khoản đã được xác thực");
        }
        
        String newOtp = generateOtp();
        user.setOtpCode(newOtp);
        user.setOtpExpiryTime(java.time.LocalDateTime.now().plusMinutes(1));
        userRepository.save(user);
        
        try {
            emailService.sendRegistrationOtp(user.getEmail(), newOtp);
        } catch (Exception e) {
            System.err.println("Info: Could not send email OTP: " + e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public Map<String, String> requestForgotPasswordOtp(String email) {
        String normalizedEmail = normalizeEmail(email);
        User user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new InvalidRequestException("EMAIL_NOT_FOUND", "Không tìm thấy tài khoản với email này"));

        String otp = generateOtp();
        redisTemplate.opsForValue().set(buildForgotPasswordOtpKey(normalizedEmail), otp, FORGOT_PASSWORD_OTP_TTL);
        emailService.sendPasswordOtp(user.getEmail(), otp);

        return Map.of("message", "OTP đã được gửi tới email của bạn");
    }

    @Transactional(readOnly = true)
    public Map<String, String> verifyForgotPasswordOtp(String email, String otp) {
        String normalizedEmail = normalizeEmail(email);
        validateOtpFormat(otp);

        String cachedOtp = redisTemplate.opsForValue().get(buildForgotPasswordOtpKey(normalizedEmail));
        if (cachedOtp == null) {
            throw new InvalidRequestException("OTP_NOT_FOUND", "OTP chưa được yêu cầu hoặc đã hết hạn");
        }
        if (!cachedOtp.equals(otp.trim())) {
            throw new InvalidRequestException("OTP_INVALID", "OTP không chính xác");
        }

        return Map.of("message", "OTP hợp lệ");
    }

    @Transactional
    public Map<String, String> resetForgotPassword(String email, String otp, String newPassword) {
        String normalizedEmail = normalizeEmail(email);
        String normalizedOtp = trimToNull(otp);
        String normalizedPassword = trimToNull(newPassword);

        validateOtpFormat(normalizedOtp);
        validatePasswordStrength(normalizedPassword);

        String cachedOtp = redisTemplate.opsForValue().get(buildForgotPasswordOtpKey(normalizedEmail));
        if (cachedOtp == null) {
            throw new InvalidRequestException("OTP_NOT_FOUND", "OTP chưa được yêu cầu hoặc đã hết hạn");
        }
        if (!cachedOtp.equals(normalizedOtp)) {
            throw new InvalidRequestException("OTP_INVALID", "OTP không chính xác");
        }

        User user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new InvalidRequestException("EMAIL_NOT_FOUND", "Không tìm thấy tài khoản với email này"));

        user.setPassword(passwordEncoder.encode(normalizedPassword));
        userRepository.save(user);
        redisTemplate.delete(buildForgotPasswordOtpKey(normalizedEmail));

        return Map.of("message", "Đặt lại mật khẩu thành công");
    }

    private User resolvePendingReRegistrationCandidate(List<User> usersByEmail, List<User> usersByPhone) {
        User pendingByEmail = singlePendingCandidate(usersByEmail);
        User pendingByPhone = singlePendingCandidate(usersByPhone);

        if (pendingByEmail != null && pendingByPhone != null && !isSameUser(pendingByEmail, pendingByPhone)) {
            return null;
        }

        return pendingByEmail != null ? pendingByEmail : pendingByPhone;
    }

    private User singlePendingCandidate(List<User> users) {
        User pending = null;
        for (User user : users) {
            if (!isPending(user)) {
                continue;
            }
            if (pending != null && !isSameUser(pending, user)) {
                return null;
            }
            pending = user;
        }
        return pending;
    }

    private boolean hasDuplicateConflict(List<User> users, User allowedPendingUser) {
        for (User user : users) {
            if (!isSameUser(user, allowedPendingUser)) {
                return true;
            }
        }
        return false;
    }

    private void refreshPendingUserRegistration(User pendingUser,
                                                RegisterRequest registerRequest,
                                                Role role,
                                                String normalizedIdentity,
                                                String normalizedPhone) {
        pendingUser.setEmail(registerRequest.email());
        pendingUser.setPhoneNumber(normalizedPhone);
        pendingUser.setPassword(passwordEncoder.encode(registerRequest.password()));
        pendingUser.setRole(role);
        pendingUser.setStatus(UserStatus.PENDING);

        String otp = generateOtp();
        pendingUser.setOtpCode(otp);
        pendingUser.setOtpExpiryTime(java.time.LocalDateTime.now().plusMinutes(1));

        Profile profile = pendingUser.getProfile();
        if (profile != null) {
            profile.setFullname(registerRequest.fullname());
            profile.setIdentityNumber(normalizedIdentity);
            profile.setPhoneNumber(normalizedPhone);
            profileRepository.save(profile);
        }

        userRepository.save(pendingUser);

        try {
            emailService.sendRegistrationOtp(pendingUser.getEmail(), otp);
        } catch (Exception e) {
            System.err.println("Info: Could not send email OTP: " + e.getMessage());
        }
    }

    private boolean isPending(User user) {
        return user != null && user.getStatus() == UserStatus.PENDING;
    }

    private boolean isSameUser(User left, User right) {
        return left != null && right != null && left.getId().equals(right.getId());
    }

    private boolean isSameProfileOfUser(Profile profile, User user) {
        return profile != null
                && user != null
                && user.getProfile() != null
                && profile.getId().equals(user.getProfile().getId());
    }

    private boolean isPhoneConflictAllowedForLinkRequest(List<User> usersByPhone, User pendingUser, Profile duplicated) {
        if (duplicated == null) {
            return false;
        }

        User ownerUser = relativeRepository.findFirstByProfileId(duplicated.getId())
                .map(Relative::getUser)
                .orElse(null);

        for (User user : usersByPhone) {
            if (isSameUser(user, pendingUser)) {
                continue;
            }
            if (ownerUser != null && isSameUser(user, ownerUser)) {
                continue;
            }
            return false;
        }
        return true;
    }

    private String generateOtp() {
        return String.format("%06d", OTP_RANDOM.nextInt(1_000_000));
    }

    private String buildForgotPasswordOtpKey(String email) {
        return FORGOT_PASSWORD_OTP_KEY_PREFIX + email.toLowerCase(Locale.ROOT);
    }

    private String normalizeEmail(String email) {
        String normalizedEmail = trimToNull(email);
        if (!StringUtils.hasText(normalizedEmail)) {
            throw new InvalidRequestException("EMAIL_REQUIRED", "Email là bắt buộc");
        }
        return normalizedEmail.toLowerCase(Locale.ROOT);
    }

    private void validateOtpFormat(String otp) {
        String normalizedOtp = trimToNull(otp);
        if (!StringUtils.hasText(normalizedOtp) || !OTP_PATTERN.matcher(normalizedOtp).matches()) {
            throw new InvalidRequestException("OTP_INVALID", "OTP phải gồm 6 chữ số");
        }
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

    private Role resolveSignupRole(String roleInput) {
        String normalized = trimToNull(roleInput);
        String selectedRole = StringUtils.hasText(normalized)
                ? normalized.toLowerCase(Locale.ROOT)
                : "user";

        if (!selectedRole.equals("user") && !selectedRole.equals("doctor")) {
            throw new backend.exception.InvalidRequestException(
                    "INVALID_ROLE",
                    "Vai tro khong hop le. Chi chap nhan user hoac doctor"
            );
        }

        Role role = findRoleCandidate(selectedRole);
        if (role == null) {
            throw new IllegalStateException("Khong tim thay role " + selectedRole);
        }
        return role;
    }

    private Role findRoleCandidate(String rawRole) {
        String candidate = rawRole.trim();
        Role role = roleRepository.findByName(candidate);
        if (role != null) {
            return role;
        }

        role = roleRepository.findByName(candidate.toUpperCase(Locale.ROOT));
        if (role != null) {
            return role;
        }

        role = roleRepository.findByName("ROLE_" + candidate.toUpperCase(Locale.ROOT));
        if (role != null) {
            return role;
        }

        return roleRepository.findByName("role_" + candidate);
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

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
