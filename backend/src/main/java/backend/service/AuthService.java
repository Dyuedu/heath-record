package backend.service;

import backend.exception.EmailDuplicateException;
import backend.exception.MultipleResourceDuplicateException;
import backend.exception.PhoneDuplicateException;
import backend.exception.ResourceDuplicateException;
import backend.model.*;
import backend.model.dto.request.LoginRequest;
import backend.model.dto.request.RegisterRequest;
import backend.repository.ProfileRepository;
import backend.repository.RelativeRepository;
import backend.repository.RoleRepository;
import backend.repository.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AuthService {
    private final PasswordEncoder passwordEncoder;
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final RelativeRepository relativeRepository;
    private final JWTService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthService(PasswordEncoder passwordEncoder, RoleRepository roleRepository, UserRepository userRepository,
            ProfileRepository profileRepository, RelativeRepository relativeRepository, JWTService jwtService,
            AuthenticationManager authenticationManager) {
        this.passwordEncoder = passwordEncoder;
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.relativeRepository = relativeRepository;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }

    @Transactional
    public void register(RegisterRequest registerRequest) {
        List<ResourceDuplicateException> errors = new ArrayList<>();
        if (isEmailExist(registerRequest.email())) {
            errors.add(new EmailDuplicateException(registerRequest.email()));
        }
        if (isPhoneNumberExist(registerRequest.phone())) {
            errors.add(new PhoneDuplicateException(registerRequest.phone()));
        }
        if (!errors.isEmpty()) {
            throw new MultipleResourceDuplicateException(errors);
        }

        Role role = roleRepository.findByName("user");

        Profile profile = new Profile();
        profile.setFullname(registerRequest.fullname());
        Profile savedProfile = profileRepository.save(profile);

        User user = new User();
        user.setEmail(registerRequest.email());
        user.setPhoneNumber(registerRequest.phone());
        user.setPassword(passwordEncoder.encode(registerRequest.password()));
        user.setRole(role);
        user.setProfile(savedProfile);
        User savedUser = userRepository.save(user);

        Relative self = new Relative();
        self.setRelationship("Me");
        self.setUser(savedUser);
        self.setProfile(savedProfile);
        relativeRepository.save(self);
    }

    public String login(LoginRequest loginRequest) {
        return verify(loginRequest);
    }

    public String verify(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.email(), loginRequest.password()));

        if (authentication.isAuthenticated()) {
            UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
            return jwtService.generateToken(userPrincipal);
        }
        throw new BadCredentialsException("Email hoặc mật khẩu không chính xác");
    }

    private Boolean isEmailExist(String email) {
        return userRepository.findByEmail(email) != null;
    }

    private Boolean isPhoneNumberExist(String phoneNumber) {
        return userRepository.findByPhoneNumber(phoneNumber) != null;
    }
}
