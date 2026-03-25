package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.User;
import backend.model.DiagnosticRecord;
import backend.model.Attachment;
import backend.model.Hospital;
import backend.model.Tag;
import backend.model.dto.request.MedicalRecordRequestDTO;
import backend.model.dto.request.DiagnosticDTO;
import backend.model.dto.response.MedicalRecordResponse;
import backend.repository.HospitalRepository;
import backend.repository.TagRepository;
import backend.repository.MedicalRecordRepository;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.UserRepository;
import backend.repository.NotificationRepository;
import backend.model.Notification;
import backend.service.mapper.MedicalRecordMapper;
import backend.model.dto.response.RelativeSearchResponse;
import backend.model.dto.response.NotificationMessageDTO;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class DoctorRecordService {

    private final MedicalRecordRepository medicalRecordRepository;
    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;
    private final MedicalRecordMapper medicalRecordMapper;
    private final HospitalRepository hospitalRepository;
    private final TagRepository tagRepository;
    private final RelativeRepository relativeRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final NotificationRepository notificationRepository;

    public DoctorRecordService(MedicalRecordRepository medicalRecordRepository,
            ProfileRepository profileRepository,
            UserRepository userRepository,
            MedicalRecordMapper medicalRecordMapper,
            HospitalRepository hospitalRepository,
            TagRepository tagRepository,
            RelativeRepository relativeRepository,
            SimpMessagingTemplate messagingTemplate,
            NotificationRepository notificationRepository) {
        this.medicalRecordRepository = medicalRecordRepository;
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
        this.medicalRecordMapper = medicalRecordMapper;
        this.hospitalRepository = hospitalRepository;
        this.tagRepository = tagRepository;
        this.relativeRepository = relativeRepository;
        this.messagingTemplate = messagingTemplate;
        this.notificationRepository = notificationRepository;
    }

    private String buildAuditField(User doctor) {
        return doctor.getEmail() != null ? "created-by:" + doctor.getEmail() : "created-by:unknown";
    }

    public MedicalRecordResponse createFullMedicalRecord(UUID doctorId, MedicalRecordRequestDTO request) {
        User doctor = userRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Bác sĩ không tồn tại"));

        if (doctor.getRole() == null || !doctor.getRole().getName().equalsIgnoreCase("DOCTOR")) {
            throw new AccessDeniedException("Chỉ bác sĩ mới có quyền tạo bệnh án");
        }

        backend.model.Profile profile = profileRepository.findById(request.getPatientProfileId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ bệnh nhân"));

        backend.model.Relative relative = relativeRepository.findFirstByProfileId(profile.getId()).orElse(null);

        Hospital hospital = null;
        if (request.getHospitalId() != null) {
            hospital = hospitalRepository.findById(request.getHospitalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bệnh viện"));
        }

        MedicalRecord record = MedicalRecord.builder()
                .title(request.getTitle() != null ? request.getTitle().trim() : null)
                .note(request.getNote())
                .doctor(doctor)
                .relative(relative)
                .profile(profile)
                .hospital(hospital)
                .datetimeStart(LocalDateTime.now())
                .datetimeEnd(LocalDateTime.now())
                .auditField(buildAuditField(doctor))
                .build();

        if (request.getDiagnostics() != null && !request.getDiagnostics().isEmpty()) {
            for (DiagnosticDTO diagDTO : request.getDiagnostics()) {
                DiagnosticRecord diagnosticRecord = DiagnosticRecord.builder()
                        .category(diagDTO.getCategory())
                        .tag(diagDTO.getTag())
                        .doctor(doctor.getProfile() != null ? doctor.getProfile().getFullname() : doctor.getEmail())
                        .data(diagDTO.getData())
                        .datetimeEnd(LocalDateTime.now())
                        .auditField(buildAuditField(doctor))
                        .profile(profile)
                        .relative(relative)
                        .encounter(record)
                        .hospital(hospital)
                        .build();

                if (diagDTO.getTag() != null && !diagDTO.getTag().isEmpty()) {
                    Tag tag = tagRepository.findByName(diagDTO.getTag())
                            .orElseGet(() -> tagRepository.save(Tag.builder().name(diagDTO.getTag()).build()));
                    diagnosticRecord.getTags().add(tag);
                }

                if (diagDTO.getImageUrls() != null && !diagDTO.getImageUrls().isEmpty()) {
                    for (String url : diagDTO.getImageUrls()) {
                        Attachment attachment = Attachment.builder()
                                .imageUrl(url)
                                .diagnosticRecord(diagnosticRecord)
                                .build();
                        diagnosticRecord.getAttachments().add(attachment);
                    }
                }
                record.getDiagnosticRecords().add(diagnosticRecord);
            }
        }

        MedicalRecord saved = medicalRecordRepository.save(record);

        String docName = doctor.getProfile() != null && doctor.getProfile().getFullname() != null
                ? doctor.getProfile().getFullname()
                : doctor.getEmail();
        String hospName = hospital != null && hospital.getName() != null ? hospital.getName() : "Phòng khám";
        String patientName = profile.getFullname() != null ? profile.getFullname() : "N/A";

        // Notify every user linked to this profile (owner account and users managing it as a relative).
        Set<UUID> recipientIds = new HashSet<>();
        if (profile.getUser() != null) {
            recipientIds.add(profile.getUser().getId());
        }
        relativeRepository.findAllByProfileId(profile.getId()).forEach(rel -> {
            if (rel.getUser() != null) {
                recipientIds.add(rel.getUser().getId());
            }
        });

        recipientIds.remove(doctor.getId());

        for (UUID recipientId : recipientIds) {
            userRepository.findById(recipientId).ifPresent(recipient -> {
                Notification notificationEntity = Notification.builder()
                        .user(recipient)
                        .title("Bệnh án mới")
                    .message("Bác sĩ " + docName + " đã thêm một bệnh án mới cho " + patientName + ".")
                        .doctorName(docName)
                        .hospitalName(hospName)
                        .recordId(saved.getId() != null ? saved.getId().toString() : "")
                        .isRead(false)
                        .createdAt(LocalDateTime.now())
                        .build();

                Notification savedNotification = notificationRepository.save(notificationEntity);

                NotificationMessageDTO notification = NotificationMessageDTO.builder()
                        .id(savedNotification.getId())
                        .title(savedNotification.getTitle())
                        .message(savedNotification.getMessage())
                    .patientName(patientName)
                        .doctorName(savedNotification.getDoctorName())
                        .hospitalName(savedNotification.getHospitalName())
                        .recordId(savedNotification.getRecordId())
                        .isRead(false)
                        .timestamp(savedNotification.getCreatedAt())
                        .build();

                messagingTemplate.convertAndSend("/topic/notifications/" + recipientId, notification);
            });
        }

        // Send success notification to Doctor
        Notification doctorNotification = Notification.builder()
                .user(doctor)
                .title("Tạo bệnh án thành công")
                .message("Bạn đã thêm thành công bệnh án mới cho bệnh nhân " + patientName)
                .doctorName(docName)
                .hospitalName(hospName)
                .recordId(saved.getId() != null ? saved.getId().toString() : "")
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();
                
        doctorNotification = notificationRepository.save(doctorNotification);
        
        NotificationMessageDTO docNotificationDto = NotificationMessageDTO.builder()
                .id(doctorNotification.getId())
                .title(doctorNotification.getTitle())
                .message(doctorNotification.getMessage())
            .patientName(patientName)
                .doctorName(doctorNotification.getDoctorName())
                .hospitalName(doctorNotification.getHospitalName())
                .recordId(doctorNotification.getRecordId())
                .isRead(false)
                .timestamp(doctorNotification.getCreatedAt())
                .build();
                
        messagingTemplate.convertAndSend("/topic/notifications/" + doctor.getId().toString(), docNotificationDto);

        return medicalRecordMapper.toMedicalRecordResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<RelativeSearchResponse> searchProfilesForDoctor(String query) {
        return profileRepository.searchProfilesForDoctor(query).stream()
                .map(profile -> {
                    User user = profile.getUser();
                    return RelativeSearchResponse.builder()
                            .id(profile.getId())
                            .fullName(profile.getFullname() != null ? profile.getFullname() : "N/A")
                            .phoneNumber(user != null ? user.getPhoneNumber() : "")
                            .dateOfBirth(profile.getDateOfBirth() != null ? profile.getDateOfBirth() : "")
                            .avatarUrl(profile.getAvatarUrl() != null ? profile.getAvatarUrl() : "")
                            .relationship("Patient")
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public backend.model.dto.response.DoctorPatientDetailResponse getPatientDetail(UUID profileId) {
        backend.model.Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ bệnh nhân"));
        
        backend.model.User user = profile.getUser();
        String roleName = user != null && user.getRole() != null ? user.getRole().getName() : "USER";
        
        backend.model.dto.response.UserResponse patientResponse = backend.model.dto.response.UserResponse.builder()
                .id(profile.getId())
                .email(user != null ? user.getEmail() : "")
                .phoneNumber(user != null ? user.getPhoneNumber() : "")
                .identityNumber(profile.getIdentityNumber() != null ? profile.getIdentityNumber() : "")
                .fullName(profile.getFullname() != null ? profile.getFullname() : "")
                .role(roleName)
                .gender(profile.getGender() != null ? profile.getGender() : "")
                .dateOfBirth(profile.getDateOfBirth() != null ? profile.getDateOfBirth() : "")
                .address(profile.getAddress() != null ? profile.getAddress() : "")
                .avatarUrl(profile.getAvatarUrl() != null ? profile.getAvatarUrl() : "")
                .status(user != null && user.getStatus() != null ? user.getStatus().name() : "")
                .build();
                
        // Patient's own history
        List<backend.model.dto.response.MedicalRecordResponse> patientHistory = medicalRecordRepository.findByProfileId(profile.getId()).stream()
                .map(medicalRecordMapper::toMedicalRecordResponse)
                .collect(Collectors.toList());

        List<backend.model.dto.response.RelativeHealthHistoryResponse> relativesList = new java.util.ArrayList<>();
        
        relativesList.add(backend.model.dto.response.RelativeHealthHistoryResponse.builder()
                .relativeId(profile.getId()) // fake ID
                .profileId(profile.getId())
                .relativeName(profile.getFullname() != null ? profile.getFullname() : "")
                .relationship("Me")
                .dateOfBirth(profile.getDateOfBirth() != null ? profile.getDateOfBirth() : "")
                .avatarUrl(profile.getAvatarUrl() != null ? profile.getAvatarUrl() : "")
                .history(patientHistory)
                .build());

        if (user != null) {
            // patient is a primary profile, load their sub-profiles
            List<backend.model.dto.response.RelativeHealthHistoryResponse> subs = relativeRepository.findByUserId(user.getId()).stream()
                .map(rel -> {
                    backend.model.Profile relProfile = rel.getProfile();
                    List<backend.model.dto.response.MedicalRecordResponse> reqHistory = medicalRecordRepository.findByRelativeId(rel.getId()).stream()
                            .map(medicalRecordMapper::toMedicalRecordResponse)
                            .collect(Collectors.toList());

                    return backend.model.dto.response.RelativeHealthHistoryResponse.builder()
                            .relativeId(rel.getId())
                            .profileId(relProfile.getId())
                            .relativeName(relProfile.getFullname() != null ? relProfile.getFullname() : "")
                            .relationship(rel.getRelationship() != null ? rel.getRelationship() : "")
                            .dateOfBirth(relProfile.getDateOfBirth() != null ? relProfile.getDateOfBirth() : "")
                            .avatarUrl(relProfile.getAvatarUrl() != null ? relProfile.getAvatarUrl() : "")
                            .history(reqHistory)
                            .build();
                })
                .collect(Collectors.toList());
            relativesList.addAll(subs);
        } else {
            // patient is a sub-profile, load their owner(s)
            List<backend.model.dto.response.RelativeHealthHistoryResponse> owners = relativeRepository.findAllByProfileId(profile.getId()).stream()
                .map(rel -> {
                    backend.model.User relUser = rel.getUser();
                    backend.model.Profile relProfile = relUser != null ? relUser.getProfile() : null;
                    
                    return backend.model.dto.response.RelativeHealthHistoryResponse.builder()
                            .relativeId(rel.getId())
                            .profileId(relProfile != null ? relProfile.getId() : (relUser != null ? relUser.getId() : UUID.randomUUID()))
                            .relativeName(relProfile != null && relProfile.getFullname() != null ? relProfile.getFullname() : (relUser != null ? relUser.getEmail() : "N/A"))
                            .relationship("Người quản lý")
                            .dateOfBirth(relProfile != null && relProfile.getDateOfBirth() != null ? relProfile.getDateOfBirth() : "")
                            .avatarUrl(relProfile != null && relProfile.getAvatarUrl() != null ? relProfile.getAvatarUrl() : "")
                            .history(new java.util.ArrayList<>()) // Owner history is generally not relevant to the patient's context.
                            .build();
                })
                .collect(Collectors.toList());
            relativesList.addAll(owners);
        }
                
        return backend.model.dto.response.DoctorPatientDetailResponse.builder()
                .patient(patientResponse)
                .relatives(relativesList)
                .build();
    }
}
