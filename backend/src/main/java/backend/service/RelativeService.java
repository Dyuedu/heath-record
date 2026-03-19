package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.Profile;
import backend.model.ProfileLinkRequest;
import backend.model.RequestType;
import backend.model.Relative;
import backend.model.User;
import backend.model.dto.request.AddRelativeRequest;
import backend.model.dto.response.AddRelativeResultResponse;
import backend.model.dto.response.RelativeResponse;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RelativeService {
    @Value("${app.feature.enableProfileLinkApproval:true}")
    private boolean enableProfileLinkApproval;

    private final RelativeRepository relativeRepository;
    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;
    private final LinkRequestService linkRequestService;

    public RelativeService(RelativeRepository relativeRepository,
                           ProfileRepository profileRepository,
                           UserRepository userRepository,
                           LinkRequestService linkRequestService) {
        this.relativeRepository = relativeRepository;
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
        this.linkRequestService = linkRequestService;
    }

    public List<Relative> findByUserId(UUID userId) {
        return relativeRepository.findByUserId(userId);
    }

    @Transactional
    public AddRelativeResultResponse addRelative(UUID userId, AddRelativeRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        Profile duplicated = null;
        if (enableProfileLinkApproval) {
            duplicated = linkRequestService.detectDuplicateProfile(
                request.identityNumber(),
                request.phoneNumber()
            ).orElse(null);
        }

        if (duplicated != null) {
            ProfileLinkRequest linkRequest = linkRequestService.createLinkRequest(
                user,
                duplicated,
                RequestType.ADD_RELATIVE_LINK,
                trimToNull(request.relationship()),
                "Yêu cầu liên kết hồ sơ khi thêm người thân"
            );

            return AddRelativeResultResponse.builder()
                .status("LINK_REQUEST_CREATED")
                .requestId(linkRequest.getId())
                .message("Hồ sơ đã tồn tại, yêu cầu liên kết đang chờ chủ hồ sơ phê duyệt")
                .relative(null)
                .build();
        }

        Profile profile = new Profile();
        profile.setFullname(trimToNull(request.fullname()));
        profile.setNickname(trimToNull(request.nickname()));
        profile.setGender(trimToNull(request.gender()));
        profile.setDateOfBirth(trimToNull(request.dateOfBirth()));
        profile.setPhoneNumber(normalizePhone(request.phoneNumber()));
        profile.setIdentityNumber(normalizeIdentity(request.identityNumber()));
        profile = profileRepository.save(profile);

        Relative relative = Relative.builder()
                .relationship(trimToNull(request.relationship()))
                .user(user)
                .profile(profile)
                .build();

        Relative savedRelative = relativeRepository.save(relative);
        RelativeResponse relativeResponse = RelativeResponse.builder()
                .id(savedRelative.getId())
            .profileId(savedRelative.getProfile() != null ? savedRelative.getProfile().getId() : null)
                .name(savedRelative.getProfile().getFullname())
                .relationship(savedRelative.getRelationship())
                .build();

        return AddRelativeResultResponse.builder()
            .status("CREATED")
            .requestId(null)
            .message("Tạo hồ sơ người thân thành công")
            .relative(relativeResponse)
            .build();
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
}
