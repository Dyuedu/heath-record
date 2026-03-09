package backend.repository;

import backend.model.Relative;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RelativeRepository extends JpaRepository<Relative, UUID> {
    Optional<Relative> findById(UUID id);
    List<Relative> findByUserId(UUID userId);
}
