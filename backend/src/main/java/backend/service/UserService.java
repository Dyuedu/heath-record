package backend.service;

import backend.model.dto.response.UserResponse;
import backend.repository.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<UserResponse> searchPatients(String phone) {
        return userRepository.findByPhoneNumberContaining(phone)
                .stream()
                .map(user -> UserResponse.builder()
                        .id(user.getId())
                        .fullName(user.getFullname())
                        .phoneNumber(user.getPhoneNumber())
                        .email(user.getEmail())
                        .role(user.getRole().getName())
                        .gender(user.getGender())
                        .dateOfBirth(user.getDateOfBirth())
                        .address(user.getAddress())
                        .build()).toList();
    }
}
