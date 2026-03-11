package backend.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Profile {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    private String fullname;
    private String gender;
    private String dateOfBirth;
    private String address;
    private String avatarUrl;

    @OneToOne(mappedBy = "profile")
    private User user;
}
