package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.Profile;
import backend.model.Relative;
import backend.model.User;
import backend.model.dto.request.AddRelativeRequest;
import backend.model.dto.response.RelativeResponse;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RelativeService {
    private final RelativeRepository relativeRepository;
    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;

    public RelativeService(RelativeRepository relativeRepository,
                           ProfileRepository profileRepository,
                           UserRepository userRepository) {
        this.relativeRepository = relativeRepository;
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
    }

    public List<Relative> findByUserId(UUID userId) {
        return relativeRepository.findByUserId(userId);
    }

    @Transactional
    public RelativeResponse addRelative(UUID userId, AddRelativeRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        Profile profile = new Profile();
        profile.setFullname(trimToNull(request.fullname()));
        profile.setNickname(trimToNull(request.nickname()));
        profile.setGender(trimToNull(request.gender()));
        profile.setDateOfBirth(trimToNull(request.dateOfBirth()));
        profile.setPhoneNumber(trimToNull(request.phoneNumber()));
        profile.setIdentityNumber(trimToNull(request.identityNumber()));
        profile = profileRepository.save(profile);

        Relative relative = Relative.builder()
                .relationship(trimToNull(request.relationship()))
                .user(user)
                .profile(profile)
                .build();

        Relative savedRelative = relativeRepository.save(relative);
        return RelativeResponse.builder()
                .id(savedRelative.getId())
            .profileId(savedRelative.getProfile() != null ? savedRelative.getProfile().getId() : null)
                .name(savedRelative.getProfile().getFullname())
                .relationship(savedRelative.getRelationship())
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
