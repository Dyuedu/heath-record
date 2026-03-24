package backend.controller;

import backend.model.dto.request.AdminUserRequest;
import backend.model.dto.response.UserResponse;
import backend.service.AdminUserService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@Validated
public class AdminController {

    private final AdminUserService adminUserService;

    public AdminController(AdminUserService adminUserService) {
        this.adminUserService = adminUserService;
    }

    @GetMapping("/dashboard/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        return ResponseEntity.ok(adminUserService.getDashboardStats());
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserResponse>> searchUsers(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(adminUserService.searchUsers(search, role, status));
    }

    @PostMapping("/users")
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody AdminUserRequest request) {
        UserResponse response = adminUserService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/users/{userId}")
    public ResponseEntity<UserResponse> updateUser(@PathVariable UUID userId,
                                                   @Valid @RequestBody AdminUserRequest request) {
        UserResponse response = adminUserService.updateUser(userId, request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/users/{userId}/status")
    public ResponseEntity<UserResponse> updateUserStatus(
            @PathVariable UUID userId,
            @RequestBody Map<String, String> body) {
        String newStatus = body.get("status");
        return ResponseEntity.ok(adminUserService.changeUserStatus(userId, newStatus));
    }

    @GetMapping("/approvals/pending")
    public ResponseEntity<List<UserResponse>> getPendingApprovals(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String role) {
        return ResponseEntity.ok(adminUserService.searchUsers(search, role, "PENDING"));
    }

    @PostMapping("/approvals/{id}/approve")
    public ResponseEntity<UserResponse> approveUser(@PathVariable UUID id) {
        return ResponseEntity.ok(adminUserService.changeUserStatus(id, "ACTIVE"));
    }

    @PostMapping("/approvals/{id}/reject")
    public ResponseEntity<UserResponse> rejectUser(@PathVariable UUID id) {
        return ResponseEntity.ok(adminUserService.changeUserStatus(id, "LOCKED"));
    }
}
