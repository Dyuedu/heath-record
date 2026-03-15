package backend.service.mapper;

import backend.model.Attachment;
import backend.model.DiagnosticRecord;
import backend.model.MedicalRecord;
import backend.model.Relative;
import backend.model.Tag;
import backend.model.dto.response.AttachmentResponse;
import backend.model.dto.response.DiagnosticRecordResponse;
import backend.model.dto.response.MedicalRecordResponse;
import backend.model.dto.response.RelativeHealthHistoryResponse;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@Component
public class MedicalRecordMapper {

    public MedicalRecordResponse toMedicalRecordResponse(MedicalRecord record) {
        if (record == null) {
            return null;
        }

        return MedicalRecordResponse.builder()
                .id(record.getId())
                .title(record.getTitle())
                .tag(record.getTag())
                .note(record.getNote())
                .doctorUserId(record.getDoctorUserId())
                .hospitalName(record.getHospital() != null ? record.getHospital().getName() : null)
                .datetimeStart(record.getDatetimeStart())
                .datetimeEnd(record.getDatetimeEnd())
                .tagNames(extractTagNames(record.getTags()))
                .diagnosticRecords(toDiagnosticRecordResponses(record.getDiagnosticRecords()))
                .build();
    }

    public List<MedicalRecordResponse> toMedicalRecordResponses(List<MedicalRecord> records) {
        if (records == null || records.isEmpty()) {
            return Collections.emptyList();
        }
        return records.stream()
                .map(this::toMedicalRecordResponse)
                .collect(Collectors.toList());
    }

    public RelativeHealthHistoryResponse toRelativeHistory(Relative relative, List<MedicalRecord> records) {
        return RelativeHealthHistoryResponse.builder()
                .relativeId(relative.getId())
                .relativeName(relative.getProfile() != null ? relative.getProfile().getFullname() : null)
                .relationship(relative.getRelationship())
                .history(toMedicalRecordResponses(records))
                .build();
    }

    private List<String> extractTagNames(List<Tag> tags) {
        if (tags == null || tags.isEmpty()) {
            return Collections.emptyList();
        }
        return tags.stream()
                .map(Tag::getName)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    private List<DiagnosticRecordResponse> toDiagnosticRecordResponses(List<DiagnosticRecord> diagnostics) {
        if (diagnostics == null || diagnostics.isEmpty()) {
            return Collections.emptyList();
        }
        return diagnostics.stream()
                .map(this::toDiagnosticRecordResponse)
                .collect(Collectors.toList());
    }

    private DiagnosticRecordResponse toDiagnosticRecordResponse(DiagnosticRecord diagnostic) {
        if (diagnostic == null) {
            return null;
        }
        return DiagnosticRecordResponse.builder()
                .id(diagnostic.getId())
                .category(diagnostic.getCategory())
                .tag(diagnostic.getTag())
                .doctor(diagnostic.getDoctor())
                .data(diagnostic.getData())
                .datetimeEnd(diagnostic.getDatetimeEnd())
                .hospitalName(diagnostic.getHospital() != null ? diagnostic.getHospital().getName() : null)
                .tagNames(extractTagNames(diagnostic.getTags()))
                .attachments(toAttachmentResponses(diagnostic.getAttachments()))
                .build();
    }

    private List<AttachmentResponse> toAttachmentResponses(List<Attachment> attachments) {
        if (attachments == null || attachments.isEmpty()) {
            return Collections.emptyList();
        }
        return attachments.stream()
                .map(this::toAttachmentResponse)
                .collect(Collectors.toList());
    }

    private AttachmentResponse toAttachmentResponse(Attachment attachment) {
        if (attachment == null) {
            return null;
        }
        return AttachmentResponse.builder()
                .id(attachment.getId())
                .imageUrl(attachment.getImageUrl())
                .build();
    }
}
