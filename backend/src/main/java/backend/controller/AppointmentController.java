package backend.controller;

import backend.model.UserPrincipal;
import backend.model.dto.request.AppointmentApprovalRequestDTO;
import backend.model.dto.request.CreateAppointmentRequestDTO;
import backend.model.dto.response.*;
import backend.service.AppointmentService;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/appointments")
@Slf4j
public class AppointmentController {
    
    private final AppointmentService appointmentService;
    
    public AppointmentController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;
    }
    
    /**
     * Lấy lịch khám của bác sĩ (7 ngày)
     * GET /api/v1/appointments/doctor/schedule?days_offset=0
     */
    @GetMapping("/doctor/schedule")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<List<DoctorScheduleDayResponse>> getDoctorSchedule(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam(value = "days_offset", defaultValue = "0") Integer daysOffset) {
        
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        List<DoctorScheduleDayResponse> schedule = appointmentService.getDoctorSchedule(
                userPrincipal.getId(),
                daysOffset
        );
        
        return ResponseEntity.ok(schedule);
    }

    /**
     * Lấy lịch khám của bác sĩ cho bệnh nhân xem trước
     * GET /api/v1/appointments/doctor/{doctorId}/schedule?days_offset=0
     */
    @GetMapping("/doctor/{doctorId}/schedule")
    @PreAuthorize("hasAnyRole('PATIENT','DOCTOR')")
    public ResponseEntity<List<DoctorScheduleDayResponse>> getDoctorScheduleById(
            @PathVariable String doctorId,
            @RequestParam(value = "days_offset", defaultValue = "0") Integer daysOffset) {

        try {
            UUID doctorUuid = UUID.fromString(doctorId);
            List<DoctorScheduleDayResponse> schedule = appointmentService.getDoctorSchedule(
                    doctorUuid,
                    daysOffset
            );
            return ResponseEntity.ok(schedule);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * Bệnh nhân yêu cầu lịch khám
     * POST /api/v1/appointments/request/{doctorId}
     */
    @PostMapping("/request/{doctorId}")
    @PreAuthorize("hasAnyRole('PATIENT','DOCTOR')")
    public ResponseEntity<AppointmentSlotResponse> requestAppointment(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable String doctorId,
            @Valid @RequestBody CreateAppointmentRequestDTO request) {
        
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        try {
            UUID doctorUuid = UUID.fromString(doctorId);
            AppointmentSlotResponse response = appointmentService.createAppointmentRequest(
                    userPrincipal.getId(),
                    doctorUuid,
                    request
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * Bác sĩ chấp thuận hoặc từ chối lịch khám
     * POST /api/v1/appointments/{appointmentId}/approval
     */
    @PostMapping("/{appointmentId}/approval")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<AppointmentApprovalResponse> approveOrRejectAppointment(
            @PathVariable Long appointmentId,
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody AppointmentApprovalRequestDTO request) {
        
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        request.setAppointmentId(appointmentId);
        
        AppointmentApprovalResponse response = appointmentService.approveOrRejectAppointment(
                userPrincipal.getId(),
                request
        );
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{appointmentId}")
    @PreAuthorize("hasAnyRole('PATIENT','DOCTOR','USER')")
    public ResponseEntity<AppointmentDetailResponse> getAppointmentDetail(
            @PathVariable Long appointmentId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        AppointmentDetailResponse response = appointmentService.getAppointmentDetail(
                userPrincipal.getId(),
                appointmentId
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/patient/me")
    @PreAuthorize("hasAnyRole('PATIENT','USER')")
    public ResponseEntity<List<AppointmentDetailResponse>> getMyAppointments(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam(value = "status", required = false) String status) {
        if (userPrincipal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        List<AppointmentDetailResponse> responses = appointmentService.getPatientAppointments(
                userPrincipal.getId(),
                status
        );
        return ResponseEntity.ok(responses);
    }
}
