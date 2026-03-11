package backend.service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import backend.model.Relative;
import backend.repository.RelativeRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import backend.exception.FileUploadException;
import backend.exception.ResourceNotFoundException;
import backend.model.MedicalRecord;
import backend.model.User;
import backend.model.dto.request.RecordCreateRequest;
import backend.model.dto.response.RecordResponse;
import backend.repository.MedicalRecordRepository;
import backend.repository.UserRepository;

@Service
@Transactional
public class RecordService {
    private final MedicalRecordRepository medicalRecordRepository;
    private final RelativeRepository relativeRepository;
    private final UserRepository userRepository;
    private final Cloudinary cloudinary;

    public RecordService(MedicalRecordRepository medicalRecordRepository, RelativeRepository relativeRepository,
                         UserRepository userRepository,
                         Cloudinary cloudinary) {
        this.medicalRecordRepository = medicalRecordRepository;
        this.relativeRepository = relativeRepository;
        this.userRepository = userRepository;
        this.cloudinary = cloudinary;
    }

    public RecordResponse createRecord(UUID doctorId, RecordCreateRequest request, List<MultipartFile> files) {
        // 1. Xác thực bác sĩ
        User doctor = userRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Bác sĩ không tồn tại"));

        // Kiểm tra role của người dùng hiện tại (Phải là DOCTOR mới được tạo record cho người khác)
        if (!doctor.getRole().getName().equalsIgnoreCase("doctor")) {
            throw new AccessDeniedException("Chỉ bác sĩ mới có quyền tạo bệnh án");
        }

        // 2. Lấy đối tượng nhận bệnh án (Bệnh nhân/Người thân)
        Relative relative = relativeRepository.findById(request.getRelativeId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ người nhận"));

        // 3. Tiến hành lưu (Bỏ qua bước check relative.getUser().equals(doctorId))
        List<String> uploadedUrls = uploadFiles(files);

        MedicalRecord record = MedicalRecord.builder()
                .title(request.getTitle().trim())
                .type(request.getType())
                .notes(request.getNotes())
                .important(request.isImportant())
                .tags(new ArrayList<>(normalizeTags(request.getTags())))
                .attachments(new ArrayList<>(uploadedUrls))
                .relative(relative)
                .doctor(doctor)
                .build();

        MedicalRecord saved = medicalRecordRepository.save(record);
        return mapToResponse(saved);
    }
    private List<String> uploadFiles(List<MultipartFile> files) {
        if (CollectionUtils.isEmpty(files)) {
            return Collections.emptyList();
        }

        List<String> urls = new ArrayList<>();
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) {
                continue;
            }
            try {
                Map<?, ?> uploaded = cloudinary.uploader()
                        .upload(file.getBytes(), ObjectUtils.asMap("folder", "health-records"));
                Object secureUrl = uploaded.get("secure_url");
                if (secureUrl != null) {
                    urls.add(secureUrl.toString());
                }
            } catch (IOException e) {
                throw new FileUploadException("Không thể tải tệp lên Cloudinary", e);
            }
        }
        return urls;
    }

    public List<RecordResponse> getRecordsByRelative(UUID userId, UUID relativeId) {
        Relative relative = relativeRepository.findById(relativeId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người thân"));

        if (!relative.getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Relative không thuộc user này");
        }

        List<MedicalRecord> records = medicalRecordRepository.findByRelativeId(relativeId);

        return records.stream()
                .map(this::mapToResponse)
                .toList();
    }

    private List<String> normalizeTags(List<String> tags) {
        if (CollectionUtils.isEmpty(tags)) {
            return Collections.emptyList();
        }
        return tags.stream()
                .filter(StringUtils::hasText)
                .map(String::trim)
                .distinct()
                .collect(Collectors.toList());
    }

    private RecordResponse mapToResponse(MedicalRecord record) {
        return RecordResponse.builder()
                .id(record.getId())
                .title(record.getTitle())
                .notes(record.getNotes())
                .important(record.isImportant())
                .tags(List.copyOf(record.getTags()))
                .attachments(List.copyOf(record.getAttachments()))
                .createdAt(record.getCreatedAt())
                .relativeId(record.getRelative().getId())
                .relativeName(record.getRelative().getProfile().getFullname())
                .build();
    }
}
