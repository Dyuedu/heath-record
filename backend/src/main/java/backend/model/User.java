package backend.model;

import java.sql.Date;
import java.util.List;
import java.util.UUID;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    private String phoneNumber;
    private String password;
    private String email;

    @OneToOne
    @JoinColumn(name = "profile_id")
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "role_id")
    private Role role;

    @OneToMany(mappedBy = "user")
    private List<Relative> relatives;
}
