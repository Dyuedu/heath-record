package backend.controller;

import backend.model.RequestStatus;
import backend.model.UserPrincipal;
import backend.model.dto.response.LinkRequestActionResponse;
import backend.model.dto.response.LinkRequestResponse;
import backend.service.LinkRequestService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/link-requests")
public class LinkRequestController {
    private final LinkRequestService linkRequestService;

    public LinkRequestController(LinkRequestService linkRequestService) {
        this.linkRequestService = linkRequestService;
    }

    @GetMapping("/inbox")
    public ResponseEntity<List<LinkRequestResponse>> getInbox(
            @RequestParam(defaultValue = "PENDING") RequestStatus status,
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        linkRequestService.expireOldPendingRequests();
        return ResponseEntity.ok(linkRequestService.getInbox(userPrincipal.getId(), status));
    }

    @GetMapping("/outbox")
    public ResponseEntity<List<LinkRequestResponse>> getOutbox(
            @RequestParam(defaultValue = "PENDING") RequestStatus status,
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        linkRequestService.expireOldPendingRequests();
        return ResponseEntity.ok(linkRequestService.getOutbox(userPrincipal.getId(), status));
    }

    @PostMapping("/{id}/approve")
    public ResponseEntity<LinkRequestActionResponse> approve(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(linkRequestService.approve(id, userPrincipal.getId()));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<LinkRequestActionResponse> reject(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(linkRequestService.reject(id, userPrincipal.getId()));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<LinkRequestActionResponse> cancel(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(linkRequestService.cancel(id, userPrincipal.getId()));
    }
}
