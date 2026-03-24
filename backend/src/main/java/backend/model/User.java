package backend.model;

import java.time.LocalDateTime;
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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserStatus status = UserStatus.PENDING;

    private String otpCode;
    private LocalDateTime otpExpiryTime;

    @OneToOne
    @JoinColumn(name = "profile_id")
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "role_id")
    private Role role;

    @OneToMany(mappedBy = "user")
    private List<Relative> relatives;
}
