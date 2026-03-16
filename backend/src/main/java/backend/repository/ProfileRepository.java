package backend.repository;

import backend.model.Profile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {

    @org.springframework.data.jpa.repository.Query("SELECT p FROM Profile p LEFT JOIN FETCH p.user u " +
           "WHERE LOWER(p.fullname) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR u.phoneNumber LIKE CONCAT('%', :query, '%')")
    java.util.List<Profile> searchProfilesForDoctor(@org.springframework.data.repository.query.Param("query") String query);
}
