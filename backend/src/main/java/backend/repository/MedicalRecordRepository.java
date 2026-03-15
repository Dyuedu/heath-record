package backend.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import backend.model.MedicalRecord;

public interface MedicalRecordRepository extends JpaRepository<MedicalRecord, UUID> {
    //List<MedicalRecord> findByRelativeId(UUID relativeId);

    @EntityGraph(attributePaths = {
            "doctor.profile",
            "hospital",
            "tags"
    })
    Page<MedicalRecord> findByProfileId(UUID profileId, Pageable pageable);

    List<MedicalRecord> findByTags_Id(UUID tagId);
}
