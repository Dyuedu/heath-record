package backend.service;

import backend.exception.InvalidRequestException;
import backend.exception.ResourceNotFoundException;
import backend.model.*;
import backend.model.dto.response.LinkRequestActionResponse;
import backend.model.dto.response.LinkRequestResponse;
import backend.repository.ProfileLinkRequestRepository;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class LinkRequestService {
    private final ProfileRepository profileRepository;
    private final RelativeRepository relativeRepository;
    private final ProfileLinkRequestRepository profileLinkRequestRepository;
    private final UserRepository userRepository;

    @Value("${app.profile-link.expire-days:7}")
    private int expireDays;

    public LinkRequestService(ProfileRepository profileRepository,
                              RelativeRepository relativeRepository,
                              ProfileLinkRequestRepository profileLinkRequestRepository,
                              UserRepository userRepository) {
        this.profileRepository = profileRepository;
        this.relativeRepository = relativeRepository;
        this.profileLinkRequestRepository = profileLinkRequestRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public Optional<Profile> detectDuplicateProfile(String identityNumber, String phoneNumber) {
        String normalizedIdentity = normalizeIdentity(identityNumber);
        if (normalizedIdentity != null) {
            Optional<Profile> byIdentity = profileRepository.findFirstByIdentityNumber(normalizedIdentity);
            if (byIdentity.isPresent()) {
                return byIdentity;
            }
        }

        String normalizedPhone = normalizePhone(phoneNumber);
        if (normalizedPhone != null) {
            return profileRepository.findFirstByPhoneNumber(normalizedPhone);
        }

        return Optional.empty();
    }

    @Transactional
    public ProfileLinkRequest createLinkRequest(User requester,
                                                Profile targetProfile,
                                                RequestType requestType,
                                                String requestedRelationship,
                                                String note) {
        expireOldPendingRequests();

        if (profileLinkRequestRepository.existsByRequesterUserIdAndTargetProfileIdAndStatus(
                requester.getId(),
                targetProfile.getId(),
                RequestStatus.PENDING
        )) {
            throw new InvalidRequestException("LINK_REQUEST_ALREADY_EXISTS", "Yêu cầu liên kết đang chờ xử lý");
        }

        User owner = resolveOwnerUser(targetProfile);

        ProfileLinkRequest request = new ProfileLinkRequest();
        request.setRequesterUser(requester);
        request.setOwnerUser(owner);
        request.setTargetProfile(targetProfile);
        request.setRequestType(requestType);
        request.setRequestedRelationship(trimToNull(requestedRelationship));
        request.setNote(trimToNull(note));
        request.setStatus(RequestStatus.PENDING);
        request.setExpiresAt(LocalDateTime.now().plusDays(expireDays));

        return profileLinkRequestRepository.save(request);
    }

    @Transactional(readOnly = true)
    public List<LinkRequestResponse> getInbox(UUID ownerUserId, RequestStatus status) {
        return profileLinkRequestRepository.findByOwnerUserIdAndStatusOrderByCreatedAtDesc(ownerUserId, status)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<LinkRequestResponse> getOutbox(UUID requesterUserId, RequestStatus status) {
        return profileLinkRequestRepository.findByRequesterUserIdAndStatusOrderByCreatedAtDesc(requesterUserId, status)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public LinkRequestActionResponse approve(UUID requestId, UUID ownerUserId) {
        expireOldPendingRequests();

        ProfileLinkRequest request = profileLinkRequestRepository.findByIdForUpdate(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy yêu cầu liên kết"));

        validateOwnerAndPending(request, ownerUserId);

        if (request.getExpiresAt().isBefore(LocalDateTime.now())) {
            request.setStatus(RequestStatus.EXPIRED);
            profileLinkRequestRepository.save(request);
            throw new InvalidRequestException("LINK_REQUEST_EXPIRED", "Yêu cầu đã hết hạn");
        }

        if (request.getRequestType() == RequestType.REGISTER_LINK) {
            User requester = request.getRequesterUser();
            requester.setProfile(request.getTargetProfile());
            userRepository.save(requester);

            if (!relativeRepository.existsByUserIdAndProfileId(requester.getId(), request.getTargetProfile().getId())) {
                Relative self = Relative.builder()
                        .relationship("Me")
                        .user(requester)
                        .profile(request.getTargetProfile())
                        .build();
                relativeRepository.save(self);
            }
        } else if (request.getRequestType() == RequestType.ADD_RELATIVE_LINK) {
            if (!relativeRepository.existsByUserIdAndProfileId(request.getRequesterUser().getId(), request.getTargetProfile().getId())) {
                Relative relative = Relative.builder()
                        .relationship(defaultRelationship(request.getRequestedRelationship()))
                        .user(request.getRequesterUser())
                        .profile(request.getTargetProfile())
                        .build();
                relativeRepository.save(relative);
            }
        }

        cancelCompetingPendingRequests(request);

        request.setStatus(RequestStatus.APPROVED);
        request.setRespondedAt(LocalDateTime.now());
        profileLinkRequestRepository.save(request);

        return LinkRequestActionResponse.builder()
                .status(RequestStatus.APPROVED.name())
                .requestId(request.getId())
                .linkedProfileId(request.getTargetProfile().getId())
                .message("Đã phê duyệt yêu cầu liên kết")
                .build();
    }

    @Transactional
    public LinkRequestActionResponse reject(UUID requestId, UUID ownerUserId) {
        expireOldPendingRequests();

        ProfileLinkRequest request = profileLinkRequestRepository.findByIdForUpdate(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy yêu cầu liên kết"));

        validateOwnerAndPending(request, ownerUserId);

        request.setStatus(RequestStatus.REJECTED);
        request.setRespondedAt(LocalDateTime.now());
        profileLinkRequestRepository.save(request);

        return LinkRequestActionResponse.builder()
                .status(RequestStatus.REJECTED.name())
                .requestId(request.getId())
                .linkedProfileId(request.getTargetProfile().getId())
                .message("Đã từ chối yêu cầu liên kết")
                .build();
    }

    @Transactional
    public LinkRequestActionResponse cancel(UUID requestId, UUID requesterUserId) {
        ProfileLinkRequest request = profileLinkRequestRepository.findByIdForUpdate(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy yêu cầu liên kết"));

        if (!request.getRequesterUser().getId().equals(requesterUserId)) {
            throw new InvalidRequestException("FORBIDDEN", "Bạn không có quyền hủy yêu cầu này");
        }

        if (request.getStatus() != RequestStatus.PENDING) {
            throw new InvalidRequestException("LINK_REQUEST_NOT_PENDING", "Yêu cầu không còn ở trạng thái chờ");
        }

        request.setStatus(RequestStatus.CANCELLED);
        request.setRespondedAt(LocalDateTime.now());
        profileLinkRequestRepository.save(request);

        return LinkRequestActionResponse.builder()
                .status(RequestStatus.CANCELLED.name())
                .requestId(request.getId())
                .linkedProfileId(request.getTargetProfile().getId())
                .message("Đã hủy yêu cầu liên kết")
                .build();
    }

    @Transactional
    public void expireOldPendingRequests() {
        List<ProfileLinkRequest> expiredRequests = profileLinkRequestRepository.findExpiredByStatus(
                RequestStatus.PENDING,
                LocalDateTime.now()
        );

        for (ProfileLinkRequest request : expiredRequests) {
            request.setStatus(RequestStatus.EXPIRED);
            request.setRespondedAt(LocalDateTime.now());
        }

        if (!expiredRequests.isEmpty()) {
            profileLinkRequestRepository.saveAll(expiredRequests);
        }
    }

    private void validateOwnerAndPending(ProfileLinkRequest request, UUID ownerUserId) {
        if (!request.getOwnerUser().getId().equals(ownerUserId)) {
            throw new InvalidRequestException("FORBIDDEN", "Bạn không có quyền xử lý yêu cầu này");
        }

        if (request.getStatus() != RequestStatus.PENDING) {
            throw new InvalidRequestException("LINK_REQUEST_NOT_PENDING", "Yêu cầu không còn ở trạng thái chờ");
        }
    }

    private void cancelCompetingPendingRequests(ProfileLinkRequest approvedRequest) {
        List<ProfileLinkRequest> competing = profileLinkRequestRepository.findByRequesterUserIdAndTargetProfileIdAndStatus(
                approvedRequest.getRequesterUser().getId(),
                approvedRequest.getTargetProfile().getId(),
                RequestStatus.PENDING
        );

        for (ProfileLinkRequest request : competing) {
            if (!request.getId().equals(approvedRequest.getId())) {
                request.setStatus(RequestStatus.CANCELLED);
                request.setRespondedAt(LocalDateTime.now());
            }
        }

        profileLinkRequestRepository.saveAll(competing);
    }

    private User resolveOwnerUser(Profile targetProfile) {
        return relativeRepository.findFirstByProfileId(targetProfile.getId())
                .map(Relative::getUser)
                .orElseThrow(() -> new InvalidRequestException(
                        "PROFILE_OWNER_NOT_FOUND",
                        "Không tìm thấy người quản lý hồ sơ đích"
                ));
    }

    private LinkRequestResponse toResponse(ProfileLinkRequest request) {
        Profile profile = request.getTargetProfile();
        return LinkRequestResponse.builder()
                .requestId(request.getId())
                .requesterUserId(request.getRequesterUser().getId())
                .ownerUserId(request.getOwnerUser().getId())
                .targetProfileId(profile.getId())
                .targetProfileName(profile.getFullname())
                .requestType(request.getRequestType())
                .requestedRelationship(request.getRequestedRelationship())
                .note(request.getNote())
                .status(request.getStatus())
                .expiresAt(request.getExpiresAt())
                .respondedAt(request.getRespondedAt())
                .createdAt(request.getCreatedAt())
                .build();
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

    private String defaultRelationship(String relationship) {
        String normalized = trimToNull(relationship);
        return normalized == null ? "Khác" : normalized;
    }
}
