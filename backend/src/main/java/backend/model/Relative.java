package backend.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.List;
import java.util.UUID;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "relatives")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Relative {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "relationship")
    private String relationship; // Mom, Dad, Brother...

    @OneToMany(mappedBy = "relative")
    private List<MedicalRecord> medicalRecords;

    @OneToOne()
    @JoinColumn(name = "profile_id")
    private Profile profile;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
