package backend.service;

import backend.exception.EmailDuplicateException;
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

    public AuthService(PasswordEncoder passwordEncoder, RoleRepository roleRepository, UserRepository userRepository,
            ProfileRepository profileRepository, RelativeRepository relativeRepository,
            LinkRequestService linkRequestService, JWTService jwtService,
            AuthenticationManager authenticationManager) {
        this.passwordEncoder = passwordEncoder;
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.relativeRepository = relativeRepository;
        this.linkRequestService = linkRequestService;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }

    @Transactional
    public RegisterResultResponse register(RegisterRequest registerRequest) {
        String normalizedIdentity = normalizeIdentity(registerRequest.identityNumber());
        String normalizedPhone = normalizePhone(registerRequest.phone());

        List<ResourceDuplicateException> errors = new ArrayList<>();
        if (isEmailExist(registerRequest.email())) {
            errors.add(new EmailDuplicateException(registerRequest.email()));
        }
        if (isPhoneNumberExist(normalizedPhone)) {
            errors.add(new PhoneDuplicateException(registerRequest.phone()));
        }
        if (!errors.isEmpty()) {
            throw new MultipleResourceDuplicateException(errors);
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

        Role role = resolveSignupRole(registerRequest.role());

        User user = new User();
        user.setEmail(registerRequest.email());
        user.setPhoneNumber(normalizedPhone);
        user.setPassword(passwordEncoder.encode(registerRequest.password()));
        user.setRole(role);
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

        return RegisterResultResponse.builder()
            .status("REGISTERED")
            .requestId(null)
            .message("Đăng ký thành công")
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
            return jwtService.generateToken(userPrincipal);
        }
        throw new BadCredentialsException("Email hoặc mật khẩu không chính xác");
    }

    private Boolean isEmailExist(String email) {
        return userRepository.findByEmail(email).isPresent();
    }

    private Boolean isPhoneNumberExist(String normalizedPhone) {
        return normalizedPhone != null && userRepository.findByPhoneNumber(normalizedPhone).isPresent();
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
