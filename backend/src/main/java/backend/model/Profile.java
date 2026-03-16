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
    private String address;
    private String avatarUrl;

    @OneToOne(mappedBy = "profile")
    private User user;
}
