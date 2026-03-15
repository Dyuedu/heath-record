package backend.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "medical_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MedicalRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "is_important")
    private boolean important;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "medical_record_tags", joinColumns = @JoinColumn(name = "record_id"))
    @Column(name = "tag_value")
    @Builder.Default
    private List<String> tags = new ArrayList<>();

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "medical_record_attachments", joinColumns = @JoinColumn(name = "record_id"))
    @Column(name = "file_url")
    @Builder.Default
    private List<String> attachments = new ArrayList<>();

    @Column(name = "record_type")
    private String type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "relative_id", nullable = false)
    private Relative relative;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id", nullable = false)
    private User doctor;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
