package backend.controller;

import java.util.Collections;
import java.util.List;
import java.util.UUID;

import backend.model.dto.request.AddRelativeRequest;
import backend.model.dto.response.MedicalRecordResponse;
import backend.model.dto.response.RelativeHealthHistoryResponse;
import backend.model.dto.response.RelativeResponse;
import backend.service.RelativeService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;

import backend.model.UserPrincipal;
import backend.model.dto.request.RecordCreateRequest;
import backend.service.RecordService;

@RestController
@RequestMapping("/api")
@Validated
public class RecordController {
    private final RecordService recordService;
    private final RelativeService relativeService;

    public RecordController(RecordService recordService, RelativeService relativeService) {
        this.recordService = recordService;
        this.relativeService = relativeService;
    }

    @PostMapping(
            value = "/relatives/{relativeId}/create-record",
            consumes = {"multipart/form-data"}
    )
    public ResponseEntity<MedicalRecordResponse> createRecord(
            @ModelAttribute @Valid RecordCreateRequest request,
            @RequestPart(value = "files", required = false) List<MultipartFile> files,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        List<MultipartFile> safeFiles = files == null ? Collections.emptyList() : files;
        MedicalRecordResponse response = recordService.createRecord(userPrincipal.getId(), request, safeFiles);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/relatives/{relativeId}/records")
    public ResponseEntity<RelativeHealthHistoryResponse> getRecordsByRelative(
            @PathVariable UUID relativeId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        RelativeHealthHistoryResponse records =
                recordService.getRecordsByRelative(userPrincipal.getId(), relativeId);

        return ResponseEntity.ok(records);
    }

    @GetMapping("/profiles/{profileId}/health-history")
    public ResponseEntity<RelativeHealthHistoryResponse> getRecordsByProfile(
            @PathVariable UUID profileId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        RelativeHealthHistoryResponse records =
                recordService.getRecordsByProfile(userPrincipal.getId(), profileId);

        return ResponseEntity.ok(records);
    }

    @PostMapping("/relatives")
    public ResponseEntity<RelativeResponse> addRelative(
            @Valid @RequestBody AddRelativeRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        RelativeResponse response = relativeService.addRelative(userPrincipal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/relatives")
    public ResponseEntity<List<RelativeResponse>> getRelatives(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        List<RelativeResponse> responses = relativeService.findByUserId(userPrincipal.getId())
                .stream()
                .map(rel -> RelativeResponse.builder()
                        .id(rel.getId())
                    .profileId(rel.getProfile() != null ? rel.getProfile().getId() : null)
                        .name(rel.getProfile().getFullname())
                        .relationship(rel.getRelationship())
                        .build())
                .toList();

        return ResponseEntity.ok(responses);
    }
}
