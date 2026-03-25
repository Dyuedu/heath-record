package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.Hospital;
import backend.model.dto.request.HospitalRequest;
import backend.model.dto.response.HospitalResponse;
import backend.repository.HospitalRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class HospitalService {

    private final HospitalRepository hospitalRepository;

    public HospitalService(HospitalRepository hospitalRepository) {
        this.hospitalRepository = hospitalRepository;
    }

    public List<HospitalResponse> getAllHospitals() {
        return hospitalRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public HospitalResponse createHospital(HospitalRequest request) {
        if (hospitalRepository.findByName(request.name()).isPresent()) {
            throw new RuntimeException("Tên bệnh viện đã tồn tại");
        }
        Hospital hospital = Hospital.builder()
                .name(request.name())
                .build();
        return mapToResponse(hospitalRepository.save(hospital));
    }

    @Transactional
    public HospitalResponse updateHospital(Long id, HospitalRequest request) {
        Hospital hospital = hospitalRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bệnh viện với ID: " + id));

        hospitalRepository.findByName(request.name()).ifPresent(existingHospital -> {
            if (!existingHospital.getId().equals(id)) {
                throw new RuntimeException("Tên bệnh viện đã tồn tại");
            }
        });

        hospital.setName(request.name());
        return mapToResponse(hospitalRepository.save(hospital));
    }

    @Transactional
    public void deleteHospital(Long id) {
        Hospital hospital = hospitalRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bệnh viện với ID: " + id));

        hospital.setActive(false);
        hospitalRepository.save(hospital);
    }

    private HospitalResponse mapToResponse(Hospital hospital) {
        return HospitalResponse.builder()
                .id(hospital.getId())
                .name(hospital.getName())
                .isActive(hospital.isActive())
                .build();
    }
}
