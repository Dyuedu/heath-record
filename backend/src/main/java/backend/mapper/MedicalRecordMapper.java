package backend.mapper;

import backend.model.MedicalRecord;
import backend.model.Tag;
import backend.model.dto.response.MedicalRecordListItemResponse;
import org.springframework.stereotype.Component;

@Component
public class MedicalRecordMapper {
    public MedicalRecordListItemResponse mapToListItem(MedicalRecord record) {

        return MedicalRecordListItemResponse.builder()
                .id(record.getId())
                .title(record.getTitle())
                .datetimeStart(record.getDatetimeStart())
                .doctorName(
                        record.getDoctor() != null
                                ? record.getDoctor().getProfile().getFullname()
                                : null
                )
                .hospitalName(
                        record.getHospital() != null
                                ? record.getHospital().getName()
                                : null
                )
                .tags(
                        record.getTags()
                                .stream()
                                .map(Tag::getName)
                                .collect(java.util.stream.Collectors.toSet())
                )
                .build();
    }
}
