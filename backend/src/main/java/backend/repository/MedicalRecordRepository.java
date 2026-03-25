package backend.repository;

import backend.model.MedicalRecord;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MedicalRecordRepository extends JpaRepository<MedicalRecord, Long> {
    List<MedicalRecord> findByRelativeId(UUID relativeId);

    List<MedicalRecord> findByProfileId(UUID profileId);

    long countByDatetimeStartAfter(LocalDateTime date);

    long countByDatetimeStartBetween(LocalDateTime start, LocalDateTime end);

    /**
     * Returns rows of [label, count] grouped by the given SQL date-truncation expression.
     * period = 'day'   -> CAST(datetime_start AS DATE)
     * period = 'week'  -> YEARWEEK(datetime_start, 1)   (MySQL)
     * period = 'month' -> DATE_FORMAT(datetime_start, '%Y-%m')
     * period = 'year'  -> YEAR(datetime_start)
     */
    @Query(value =
        "SELECT label, COUNT(*) AS cnt FROM (" +
        "  SELECT CASE :period" +
        "    WHEN 'day'   THEN TO_CHAR(datetime_start, 'DD/MM')" +
        "    WHEN 'week'  THEN CONCAT('T', TO_CHAR(datetime_start, 'IW'))" +
        "    WHEN 'month' THEN TO_CHAR(datetime_start, 'MM/YYYY')" +
        "    WHEN 'year'  THEN TO_CHAR(datetime_start, 'YYYY')" +
        "    ELSE TO_CHAR(datetime_start, 'MM/YYYY')" +
        "  END AS label," +
        "  datetime_start" +
        "  FROM encounters e" +
        "  WHERE e.datetime_start BETWEEN :start AND :end" +
        ") t GROUP BY label ORDER BY MIN(datetime_start)",
        nativeQuery = true)
    List<Object[]> countGroupedByPeriod(
        @Param("period") String period,
        @Param("start") LocalDateTime start,
        @Param("end") LocalDateTime end);
}
