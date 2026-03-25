package backend.service;

import backend.exception.EmailDuplicateException;
import backend.exception.IdentityDuplicateException;
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
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

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

    public AuthService(PasswordEncoder passwordEncoder, RoleRepository roleRepository, UserRepository userRepository,
            ProfileRepository profileRepository, RelativeRepository relativeRepository,
            LinkRequestService linkRequestService, JWTService jwtService,
            AuthenticationManager authenticationManager, EmailService emailService) {
        this.passwordEncoder = passwordEncoder;
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.relativeRepository = relativeRepository;
        this.linkRequestService = linkRequestService;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.emailService = emailService;
    }

    @Transactional
    public RegisterResultResponse register(RegisterRequest registerRequest) {
        String normalizedIdentity = normalizeIdentity(registerRequest.identityNumber());
        String normalizedPhone = normalizePhone(registerRequest.phone());

        List<User> usersByEmail = userRepository.findAllByEmail(registerRequest.email());
        List<User> usersByPhone = normalizedPhone != null
                ? userRepository.findAllByPhoneNumber(normalizedPhone)
                : List.of();
        Profile existingByIdentity = normalizedIdentity != null
                ? profileRepository.findFirstByIdentityNumber(normalizedIdentity).orElse(null)
                : null;
        User pendingUser = resolvePendingReRegistrationCandidate(usersByEmail, usersByPhone);

        List<ResourceDuplicateException> errors = new ArrayList<>();
        if (hasDuplicateConflict(usersByEmail, pendingUser)) {
            errors.add(new EmailDuplicateException(registerRequest.email()));
        }
        if (hasDuplicateConflict(usersByPhone, pendingUser)) {
            errors.add(new PhoneDuplicateException(registerRequest.phone()));
        }
        if (existingByIdentity != null && !isSameProfileOfUser(existingByIdentity, pendingUser)) {
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

        Profile duplicated = null;
        if (enableProfileLinkApproval) {
            duplicated = linkRequestService.detectDuplicateProfile(
                normalizedIdentity,
                normalizedPhone
            ).orElse(null);
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

    private String generateOtp() {
        return String.format("%06d", new java.util.Random().nextInt(999999));
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
