package backend.service;

import backend.model.Relative;
import backend.repository.RelativeRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class RelativeService {
    private final RelativeRepository relativeRepository;

    public RelativeService(RelativeRepository relativeRepository) {
        this.relativeRepository = relativeRepository;
    }

    public List<Relative> findByUserId(UUID userId) {
        return relativeRepository.findByUserId(userId);
    }
}
