package backend.service;

import backend.exception.DuplicateResourceException;
import backend.model.User;
import backend.model.UserPrincipal;
import backend.model.dto.request.LoginRequest;
import backend.model.dto.request.RegisterRequest;
import backend.repository.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final JWTService jwtService;
    private final AuthenticationManager authenticationManager;
    private final CustomUserDetailService customUserDetailService;

    public AuthService(PasswordEncoder passwordEncoder, UserRepository userRepository, JWTService jwtService, AuthenticationManager authenticationManager, CustomUserDetailService customUserDetailService) {
        this.passwordEncoder = passwordEncoder;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.customUserDetailService = customUserDetailService;
    }

    public void register(RegisterRequest registerRequest) {
        if(isEmailExist(registerRequest.email())){
            throw new DuplicateResourceException(0, "email", "email đã tồn tại");
        }
        User user = new User();
        user.setEmail(registerRequest.email());
        user.setPassword(passwordEncoder.encode(registerRequest.password()));
        userRepository.save(user);
    }

    public String login(LoginRequest loginRequest) {
        return verify(loginRequest);
    }

    public String verify(LoginRequest loginRequest) {
        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(loginRequest.email(), loginRequest.password());
        Authentication authentication = authenticationManager.authenticate(authenticationToken);
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        if (userPrincipal != null) {
            return jwtService.generateToken(userPrincipal);
        }
        return null;
    }

    private Boolean isEmailExist(String email) {
        return userRepository.findByEmail(email) != null;
    }
}
