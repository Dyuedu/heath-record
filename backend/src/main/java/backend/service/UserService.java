package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.User;
import backend.model.dto.response.PatientDetailResponse;
import backend.model.dto.response.PatientRelativeRecordResponse;
import backend.model.dto.response.RecordResponse;
import backend.model.dto.response.UserResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final RelativeRepository relativeRepository;
    private final MedicalRecordRepository medicalRecordRepository;

    public UserService(UserRepository userRepository,
                       RelativeRepository relativeRepository,
                       MedicalRecordRepository medicalRecordRepository) {
        this.userRepository = userRepository;
        this.relativeRepository = relativeRepository;
        this.medicalRecordRepository = medicalRecordRepository;
    }

    public List<UserResponse> searchPatients(String phone) {
        return userRepository.findByPhoneNumberContaining(phone)
                .stream()
                .map(this::mapToUserResponse)
                .toList();
    }

    public PatientDetailResponse getPatientDetail(UUID patientId) {
        User patient = userRepository.findById(patientId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bệnh nhân"));

        List<PatientRelativeRecordResponse> relatives = relativeRepository.findByUserId(patientId)
                .stream()
                .map(relative -> PatientRelativeRecordResponse.builder()
                        .id(relative.getId())
                        .name(relative.getName())
                        .relationship(relative.getRelationship())
                        .records(
                                medicalRecordRepository.findByRelativeId(relative.getId())
                                        .stream()
                                        .map(this::mapToRecordResponse)
                                        .toList()
                        )
                        .build())
                .toList();

        return PatientDetailResponse.builder()
                .patient(mapToUserResponse(patient))
                .relatives(relatives)
                .build();
    }

    private UserResponse mapToUserResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .fullName(user.getFullname())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .role(user.getRole().getName())
                .gender(user.getGender())
                .dateOfBirth(user.getDateOfBirth())
                .address(user.getAddress())
                .avatarUrl(user.getAvatarUrl())
                .build();
    }

    private RecordResponse mapToRecordResponse(MedicalRecord record) {
        return RecordResponse.builder()
                .id(record.getId())
                .title(record.getTitle())
                .notes(record.getNotes())
                .important(record.isImportant())
                .tags(List.copyOf(record.getTags()))
                .attachments(List.copyOf(record.getAttachments()))
                .createdAt(record.getCreatedAt())
                .relativeId(record.getRelative().getId())
                .relativeName(record.getRelative().getName())
                .build();
    }
}
