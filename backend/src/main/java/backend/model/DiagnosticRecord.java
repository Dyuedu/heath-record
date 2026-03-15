package backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "diagnostic_records")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DiagnosticRecord {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 50)
    private DiagnosticRecordType type;

    @Column(name = "note", columnDefinition = "jsonb")
    private String note;

    @Column(name = "datetime")
    private LocalDateTime datetime;

    // thuộc medical record nào
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "medical_record_id", nullable = false)
    private MedicalRecord medicalRecord;

    // tags
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "diagnostic_record_tags",
            joinColumns = @JoinColumn(name = "diagnostic_record_id"),
            inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    private Set<Tag> tags;

    // attachments
    @OneToMany(mappedBy = "diagnosticRecord", fetch = FetchType.LAZY)
    private Set<Attachment> attachments;
}
