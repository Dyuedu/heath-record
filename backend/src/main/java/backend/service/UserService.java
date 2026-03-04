package backend.service;

import backend.repository.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final JWTService jwtService;
    private final AuthenticationManager authenticationManager;
    private final CustomUserDetailService customUserDetailService;

    public UserService(PasswordEncoder passwordEncoder, UserRepository userRepository, JWTService jwtService, AuthenticationManager authenticationManager, CustomUserDetailService customUserDetailService) {
        this.passwordEncoder = passwordEncoder;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.customUserDetailService = customUserDetailService;
    }

}
