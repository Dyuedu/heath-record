package backend.repository;

import backend.model.MedicalRecord;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MedicalRecordRepository extends JpaRepository<MedicalRecord, Long> {
    List<MedicalRecord> findByRelativeId(UUID relativeId);

    List<MedicalRecord> findByProfileId(UUID profileId);
}
