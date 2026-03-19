package backend.repository;

import backend.model.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {

    @Query("SELECT p FROM Profile p LEFT JOIN FETCH p.user u " +
           "WHERE LOWER(p.fullname) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR u.phoneNumber LIKE CONCAT('%', :query, '%')")
    java.util.List<Profile> searchProfilesForDoctor(@Param("query") String query);

    Optional<Profile> findFirstByIdentityNumber(String identityNumber);

    Optional<Profile> findFirstByPhoneNumber(String phoneNumber);
}
