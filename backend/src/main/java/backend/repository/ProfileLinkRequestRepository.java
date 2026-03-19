package backend.repository;

import backend.model.ProfileLinkRequest;
import backend.model.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProfileLinkRequestRepository extends JpaRepository<ProfileLinkRequest, UUID> {

    List<ProfileLinkRequest> findByOwnerUserIdAndStatusOrderByCreatedAtDesc(UUID ownerUserId, RequestStatus status);

    List<ProfileLinkRequest> findByRequesterUserIdAndStatusOrderByCreatedAtDesc(UUID requesterUserId, RequestStatus status);

    boolean existsByRequesterUserIdAndTargetProfileIdAndStatus(UUID requesterUserId,
                                                                UUID targetProfileId,
                                                                RequestStatus status);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT r FROM ProfileLinkRequest r WHERE r.id = :id")
    Optional<ProfileLinkRequest> findByIdForUpdate(@Param("id") UUID id);

    List<ProfileLinkRequest> findByRequesterUserIdAndTargetProfileIdAndStatus(
            UUID requesterUserId,
            UUID targetProfileId,
            RequestStatus status
    );

    @Query("SELECT r FROM ProfileLinkRequest r WHERE r.status = :status AND r.expiresAt < :now")
    List<ProfileLinkRequest> findExpiredByStatus(@Param("status") RequestStatus status,
                                                 @Param("now") LocalDateTime now);
}
