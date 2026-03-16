package backend.repository;

import backend.model.Relative;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RelativeRepository extends JpaRepository<Relative, UUID> {
    Optional<Relative> findById(UUID id);
    List<Relative> findByUserId(UUID userId);
    Optional<Relative> findByProfileId(UUID profileId);

    @Query("SELECT r FROM Relative r LEFT JOIN r.profile p LEFT JOIN r.user u " +
           "WHERE (LOWER(p.fullname) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR u.phoneNumber LIKE CONCAT('%', :query, '%'))")
    List<Relative> searchRelatives(@Param("query") String query);
}
