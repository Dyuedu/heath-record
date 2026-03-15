package backend.model;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "diagnostic_records")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DiagnosticRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String category;

    @Column(name = "tag")
    private String tag;

    @Column(name = "doctor")
    private String doctor;

    @Column(name = "data", columnDefinition = "TEXT")
    private String data;

    @Column(name = "datetime_end")
    private LocalDateTime datetimeEnd;

    @Column(name = "audit_field")
    private String auditField;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "relative_id", nullable = false)
    private Relative relative;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "encounter_id")
    private MedicalRecord encounter;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hospital_id")
    private Hospital hospital;

    @ManyToMany
    @JoinTable(
            name = "diagnostic_record_tags",
            joinColumns = @JoinColumn(name = "diagnostic_record_id"),
            inverseJoinColumns = @JoinColumn(name = "tag_id"))
    @Builder.Default
    private List<Tag> tags = new ArrayList<>();

    @OneToMany(mappedBy = "diagnosticRecord", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Attachment> attachments = new ArrayList<>();
}
