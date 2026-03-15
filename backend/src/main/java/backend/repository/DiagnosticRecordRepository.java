package backend.repository;

import backend.model.DiagnosticRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface DiagnosticRecordRepository extends JpaRepository<DiagnosticRecord, UUID> {

}
