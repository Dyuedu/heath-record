package backend.model;

import jakarta.persistence.*;
import java.util.List;
import java.util.UUID;
import lombok.*;

@Entity
@Table(name = "relatives")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
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
