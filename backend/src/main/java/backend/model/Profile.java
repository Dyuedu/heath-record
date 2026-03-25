package backend.model;

import java.util.UUID;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Profile {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    private String fullname;
    private String nickname;
    private String identityNumber;
    private String gender;
    private String dateOfBirth;
    private String phoneNumber;
    private String address;
    private String avatarUrl;
    private String cccdFrontUrl;
    private String cccdBackUrl;
    private String diplomaUrl;

    @Column(columnDefinition = "TEXT")
    private String allergy;

    @Column(columnDefinition = "TEXT")
    private String chronicDisease;

    @Column(columnDefinition = "TEXT")
    private String clinicalNotes;

    @Column(length = 10)
    private String bloodGroup;

    @OneToOne(mappedBy = "profile")
    private User user;
}
