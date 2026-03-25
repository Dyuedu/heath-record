package backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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

    @Query("""
            SELECT u
            FROM User u
            LEFT JOIN u.profile p
            WHERE LOWER(COALESCE(u.phoneNumber, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
               OR LOWER(COALESCE(p.identityNumber, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
               OR LOWER(COALESCE(p.phoneNumber, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
            """)
    List<User> searchByPhoneOrIdentity(@Param("keyword") String keyword);

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

    @Query(value =
        "SELECT label, COUNT(*) AS cnt FROM (" +
        "  SELECT CASE :period" +
        "    WHEN 'day'   THEN TO_CHAR(created_at, 'DD/MM')" +
        "    WHEN 'week'  THEN CONCAT('T', TO_CHAR(created_at, 'IW'))" +
        "    WHEN 'month' THEN TO_CHAR(created_at, 'MM/YYYY')" +
        "    WHEN 'year'  THEN TO_CHAR(created_at, 'YYYY')" +
        "    ELSE TO_CHAR(created_at, 'MM/YYYY')" +
        "  END AS label," +
        "  created_at" +
        "  FROM users u" +
        "  WHERE u.created_at BETWEEN :start AND :end" +
        ") t GROUP BY label ORDER BY MIN(created_at)",
        nativeQuery = true)
    List<Object[]> countUsersGroupedByPeriod(
        @Param("period") String period,
        @Param("start") java.time.LocalDateTime start,
        @Param("end") java.time.LocalDateTime end);
}
