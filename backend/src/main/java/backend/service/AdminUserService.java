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
import backend.repository.ProfileRepository;
import backend.repository.RoleRepository;
import backend.repository.UserRepository;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class AdminUserService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminUserService(UserRepository userRepository,
                            ProfileRepository profileRepository,
                            RoleRepository roleRepository,
                            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(this::mapToUserResponse)
                .toList();
    }

    @Transactional
    public UserResponse createUser(AdminUserRequest request) {
        String email = trimToNull(request.email());
        String phone = trimToNull(request.phoneNumber());

        validateEmail(email, null);
        validatePhone(phone, null);

        String rawPassword = trimToNull(request.password());
        if (!StringUtils.hasText(rawPassword)) {
            throw new InvalidRequestException("PASSWORD_REQUIRED", "Mật khẩu là bắt buộc khi tạo người dùng mới");
        }

        Role role = resolveRole(request.role());

        Profile profile = new Profile();
        applyProfile(profile, request);
        profile = profileRepository.save(profile);

        User user = new User();
        user.setEmail(email);
        user.setPhoneNumber(phone);
        user.setPassword(passwordEncoder.encode(rawPassword));
        user.setRole(role);
        user.setProfile(profile);

        User saved = userRepository.save(user);
        return mapToUserResponse(saved);
    }

    @Transactional
    public UserResponse updateUser(UUID userId, AdminUserRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        String email = trimToNull(request.email());
        String phone = trimToNull(request.phoneNumber());

        validateEmail(email, user.getId());
        validatePhone(phone, user.getId());

        user.setEmail(email);
        user.setPhoneNumber(phone);

        String newPassword = trimToNull(request.password());
        if (StringUtils.hasText(newPassword)) {
            user.setPassword(passwordEncoder.encode(newPassword));
        }

        Role role = resolveRole(request.role());
        user.setRole(role);

        Profile profile = user.getProfile();
        if (profile == null) {
            profile = new Profile();
        }
        applyProfile(profile, request);
        profile = profileRepository.save(profile);
        user.setProfile(profile);

        User saved = userRepository.save(user);
        return mapToUserResponse(saved);
    }

    private void validateEmail(String email, UUID currentUserId) {
        if (!StringUtils.hasText(email)) {
            throw new InvalidRequestException("EMAIL_REQUIRED", "Email là bắt buộc");
        }
        User existing = userRepository.findByEmail(email);
        if (existing != null && (currentUserId == null || !existing.getId().equals(currentUserId))) {
            throw new EmailDuplicateException(email);
        }
    }

    private void validatePhone(String phone, UUID currentUserId) {
        if (!StringUtils.hasText(phone)) {
            throw new InvalidRequestException("PHONE_REQUIRED", "Số điện thoại là bắt buộc");
        }
        User existing = userRepository.findByPhoneNumber(phone);
        if (existing != null && (currentUserId == null || !existing.getId().equals(currentUserId))) {
            throw new PhoneDuplicateException(phone);
        }
    }

    private void applyProfile(Profile profile, AdminUserRequest request) {
        profile.setFullname(trimToNull(request.fullName()));
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
                .avatarUrl(profile != null ? profile.getAvatarUrl() : null)
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
