package backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.model.User;
import backend.model.UserStatus;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);

    Optional<User> findByPhoneNumber(String phoneNumber);

    Optional<User> findById(UUID id);

    List<User> findByPhoneNumberContaining(String phone);

    Optional<User> findByProfileId(UUID profileId);

    // For Admin Dashboard
    long countByStatus(UserStatus status);
    long countByStatusNot(UserStatus status);

    // For Admin User Management
    @org.springframework.data.jpa.repository.Query(
            value = "SELECT u.* FROM users u " +
                    "LEFT JOIN profile p ON p.id = u.profile_id " +
                    "LEFT JOIN roles r ON r.id = u.role_id " +
                    "WHERE (CAST(:status AS varchar) IS NULL OR u.status = CAST(:status AS varchar)) " +
                    "AND (CAST(:roleName AS varchar) IS NULL OR r.name = CAST(:roleName AS varchar)) " +
                    "AND (CAST(:search AS varchar) IS NULL " +
                    "OR LOWER(CAST(u.email AS text)) LIKE LOWER(CONCAT('%', CAST(:search AS varchar), '%')) " +
                    "OR LOWER(CAST(p.fullname AS text)) LIKE LOWER(CONCAT('%', CAST(:search AS varchar), '%')))",
            nativeQuery = true)
    List<User> searchUsers(
            @org.springframework.data.repository.query.Param("search") String search,
            @org.springframework.data.repository.query.Param("roleName") String roleName,
            @org.springframework.data.repository.query.Param("status") String status
    );
}
