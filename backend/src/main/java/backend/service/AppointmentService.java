package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.exception.AccessDeniedException;
import backend.model.*;
import backend.model.dto.request.AppointmentApprovalRequestDTO;
import backend.model.dto.request.CreateAppointmentRequestDTO;
import backend.model.dto.response.*;
import backend.repository.AppointmentRepository;
import backend.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
@Slf4j
public class AppointmentService {
    
    private final AppointmentRepository appointmentRepository;
    private final UserRepository userRepository;
    
    // Định nghĩa các time slot (8h - 21h)
    private static final int[] SLOT_START_HOURS = {8, 9, 11, 14, 15, 16, 17, 18};
    private static final int[] SLOT_START_MINUTES = {0, 30, 0, 0, 30, 0, 30, 0};
    private static final int SLOT_DURATION_MINUTES = 90;  // 1.5 giờ
    
    public AppointmentService(
            AppointmentRepository appointmentRepository,
            UserRepository userRepository) {
        this.appointmentRepository = appointmentRepository;
        this.userRepository = userRepository;
    }

    private String normalizeRole(User user) {
        if (user == null || user.getRole() == null || user.getRole().getName() == null) {
            return "";
        }
        return user.getRole().getName().trim().toUpperCase();
    }

    private boolean isDoctor(User user) {
        return normalizeRole(user).contains("DOCTOR");
    }

    private boolean isPatient(User user) {
        String role = normalizeRole(user);
        return role.contains("PATIENT") || role.contains("USER");
    }

    private String resolvePatientName(User user, String fallback) {
        if (user != null && user.getProfile() != null
                && StringUtils.hasText(user.getProfile().getFullname())) {
            return user.getProfile().getFullname();
        }
        if (StringUtils.hasText(fallback)) {
            return fallback.trim();
        }
        if (user != null && StringUtils.hasText(user.getEmail())) {
            return user.getEmail();
        }
        return "";
    }

    private String resolvePatientPhone(User user, String fallback) {
        if (user != null && user.getProfile() != null
                && StringUtils.hasText(user.getProfile().getPhoneNumber())) {
            return user.getProfile().getPhoneNumber();
        }
        if (user != null && StringUtils.hasText(user.getPhoneNumber())) {
            return user.getPhoneNumber();
        }
        return StringUtils.hasText(fallback) ? fallback.trim() : "";
    }
    
    /**
     * Lấy lịch của bác sĩ cho khoảng ngày
     */
    @Transactional(readOnly = true)
    public List<DoctorScheduleDayResponse> getDoctorSchedule(UUID doctorId, Integer daysOffset) {
        User doctor = userRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Bác sĩ không tồn tại"));
        
        if (doctor.getRole() == null || !doctor.getRole().getName().equalsIgnoreCase("DOCTOR")) {
            throw new AccessDeniedException("Chỉ bác sĩ mới có quyền truy cập lịch khám");
        }
        
        // Lấy 7 ngày từ ngày hôm nay + daysOffset
        LocalDate startDate = LocalDate.now().plusDays(daysOffset);
        LocalDate endDate = startDate.plusDays(6);
        
        List<Appointment> appointments = appointmentRepository
                .findDoctorScheduleByDateRange(doctorId, startDate, endDate);
        
        Map<LocalDate, List<Appointment>> appointmentsByDate = appointments.stream()
                .collect(Collectors.groupingBy(Appointment::getAppointmentDate));
        
        List<DoctorScheduleDayResponse> schedules = new ArrayList<>();
        
        for (int i = 0; i < 7; i++) {
            LocalDate date = startDate.plusDays(i);
            List<AppointmentSlotResponse> slots = generateSlots(
                date,
                appointmentsByDate.getOrDefault(date, new ArrayList<>())
            );
            
            long pendingCount = slots.stream()
                    .filter(s -> "PENDING".equals(s.getStatus()))
                    .count();
            
            long bookedCount = slots.stream()
                    .filter(s -> "BOOKED".equals(s.getStatus()))
                    .count();
            
            schedules.add(DoctorScheduleDayResponse.builder()
                    .date(date)
                    .dayOfWeek(date.getDayOfWeek().toString())
                    .slots(slots)
                    .pendingCount((int) pendingCount)
                    .bookedCount((int) bookedCount)
                    .build());
        }
        
        return schedules;
    }
    
    /**
     * Sinh ra danh sách 8 slot cố định cho một ngày
     */
    private List<AppointmentSlotResponse> generateSlots(LocalDate date, List<Appointment> existingAppointments) {
        List<AppointmentSlotResponse> slots = new ArrayList<>();
        
        Map<Integer, Appointment> appointmentMap = existingAppointments.stream()
                .collect(Collectors.toMap(
                        Appointment::getSlotNumber,
                        a -> a,
                        (a1, a2) -> {
                            LocalDateTime u1 = a1.getUpdatedAt();
                            LocalDateTime u2 = a2.getUpdatedAt();
                            if (u1 == null) return a2;
                            if (u2 == null) return a1;
                            return u2.isAfter(u1) ? a2 : a1;
                        }
                ));
        
        for (int slotNum = 1; slotNum <= 8; slotNum++) {
            LocalTime startTime = LocalTime.of(SLOT_START_HOURS[slotNum - 1], SLOT_START_MINUTES[slotNum - 1]);
            LocalTime endTime = startTime.plusMinutes(SLOT_DURATION_MINUTES);
            
            Appointment existing = appointmentMap.get(slotNum);
            
            if (existing != null) {
                slots.add(AppointmentSlotResponse.builder()
                        .appointmentId(existing.getId())
                        .slotNumber(slotNum)
                        .slotStartTime(startTime)
                        .slotEndTime(endTime)
                        .status(existing.getStatus().toString())
                        .patientName(existing.getPatientName())
                        .patientPhone(existing.getPatientPhone())
                        .notes(existing.getNotes())
                        .build());
            } else {
                slots.add(AppointmentSlotResponse.builder()
                        .appointmentId(null)
                        .slotNumber(slotNum)
                        .slotStartTime(startTime)
                        .slotEndTime(endTime)
                        .status("AVAILABLE")
                        .patientName(null)
                        .patientPhone(null)
                        .notes(null)
                        .build());
            }
        }
        
        return slots;
    }
    
    /**
     * Bệnh nhân yêu cầu lịch khám
     */
    public AppointmentSlotResponse createAppointmentRequest(
            UUID requesterId,
            UUID doctorId,
            CreateAppointmentRequestDTO request) {

        User actor = userRepository.findById(requesterId)
                .orElseThrow(() -> new ResourceNotFoundException("Người dùng không tồn tại"));

        User doctor = userRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Bác sĩ không tồn tại"));
        
        if (doctor.getRole() == null || !doctor.getRole().getName().equalsIgnoreCase("DOCTOR")) {
            throw new AccessDeniedException("ID không hợp lệ");
        }

        if (!isDoctor(actor) && !isPatient(actor)) {
            throw new AccessDeniedException("Bạn không có quyền yêu cầu lịch khám");
        }

        if (isDoctor(actor) && !doctor.getId().equals(actor.getId())) {
            throw new AccessDeniedException("Bác sĩ chỉ có thể tạo lịch cho chính mình");
        }
        
        // Slot mặc định luôn là AVAILABLE trên UI; DB chỉ lưu khi có request/booked
        Optional<Appointment> existing = appointmentRepository
                .findByDoctorIdAndAppointmentDateAndSlotNumber(
                    doctorId,
                    request.getAppointmentDate(),
                    request.getSlotNumber()
                );

        Appointment appointment;
        if (existing.isPresent()) {
            appointment = existing.get();
            if (!appointment.getStatus().equals(AppointmentStatus.AVAILABLE)) {
                throw new IllegalArgumentException("Slot này không còn trống hoặc đã được đặt");
            }
        } else {
            if (request.getSlotNumber() < 1 || request.getSlotNumber() > 8) {
                throw new IllegalArgumentException("Slot không hợp lệ");
            }
            LocalTime startTime = LocalTime.of(
                    SLOT_START_HOURS[request.getSlotNumber() - 1],
                    SLOT_START_MINUTES[request.getSlotNumber() - 1]
            );
            LocalTime endTime = startTime.plusMinutes(SLOT_DURATION_MINUTES);

            appointment = Appointment.builder()
                    .doctor(doctor)
                    .appointmentDate(request.getAppointmentDate())
                    .slotNumber(request.getSlotNumber())
                    .slotStartTime(startTime)
                    .slotEndTime(endTime)
                    .status(AppointmentStatus.AVAILABLE)
                    .build();
        }

        appointment.setStatus(AppointmentStatus.PENDING);
        if (isPatient(actor)) {
            appointment.setPatient(actor);
            appointment.setPatientName(resolvePatientName(actor, request.getPatientName()));
            appointment.setPatientPhone(resolvePatientPhone(actor, request.getPatientPhone()));
        } else {
            appointment.setPatient(null);
            appointment.setPatientName(request.getPatientName());
            appointment.setPatientPhone(request.getPatientPhone());
        }
        appointment.setNotes(request.getNotes());
        appointment.setUpdatedAt(LocalDateTime.now());

        Appointment saved = appointmentRepository.save(appointment);
        
        return toSlotResponse(saved);
    }
    
    /**
     * Bác sĩ chấp thuận hoặc từ chối lịch khám
     */
    public AppointmentApprovalResponse approveOrRejectAppointment(
            UUID doctorId,
            AppointmentApprovalRequestDTO request) {
        
        User doctor = userRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Bác sĩ không tồn tại"));
        
        Appointment appointment = appointmentRepository.findById(request.getAppointmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Lịch khám không tồn tại"));
        
        // Kiểm tra quyền sở hữu
        if (!appointment.getDoctor().getId().equals(doctorId)) {
            throw new AccessDeniedException("Bạn không có quyền duyệt lịch này");
        }
        
        // Chỉ có thể duyệt nếu là PENDING
        if (!appointment.getStatus().equals(AppointmentStatus.PENDING)) {
            throw new IllegalArgumentException("Chỉ có thể duyệt lịch ở trạng thái chờ duyệt");
        }
        
        if (request.getApprove()) {
            appointment.setStatus(AppointmentStatus.BOOKED);
            appointment.setNotes(request.getNotes() != null ? request.getNotes() : appointment.getNotes());
        } else {
            // Từ chối: quay lại AVAILABLE
            appointment.setStatus(AppointmentStatus.AVAILABLE);
            appointment.setPatientName(null);
            appointment.setPatientPhone(null);
            appointment.setNotes(null);
            appointment.setPatient(null);
        }
        
        appointment.setRespondedAt(LocalDateTime.now());
        appointment.setUpdatedAt(LocalDateTime.now());
        
        Appointment saved = appointmentRepository.save(appointment);
        
        return AppointmentApprovalResponse.builder()
                .appointmentId(saved.getId())
                .status(saved.getStatus().toString())
                .message(request.getApprove() ? "Đã chấp thuận lịch khám" : "Đã từ chối lịch khám")
                .respondedAt(saved.getRespondedAt())
                .slotDetails(toSlotResponse(saved))
                .build();
    }

    @Transactional(readOnly = true)
    public AppointmentDetailResponse getAppointmentDetail(UUID requesterId, Long appointmentId) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Lịch khám không tồn tại"));

        boolean isDoctorOwner = appointment.getDoctor() != null
                && appointment.getDoctor().getId().equals(requesterId);
        boolean isPatientOwner = appointment.getPatient() != null
                && appointment.getPatient().getId().equals(requesterId);

        if (!isDoctorOwner && !isPatientOwner) {
            throw new AccessDeniedException("Bạn không có quyền xem lịch khám này");
        }

        return toDetailResponse(appointment);
    }

    @Transactional(readOnly = true)
    public List<AppointmentDetailResponse> getPatientAppointments(UUID patientId, String statusFilter) {
        AppointmentStatus filter = null;
        if (StringUtils.hasText(statusFilter)) {
            try {
                filter = AppointmentStatus.valueOf(statusFilter.trim().toUpperCase());
            } catch (IllegalArgumentException ex) {
                throw new IllegalArgumentException("Trạng thái không hợp lệ");
            }
        }

        List<Appointment> appointments = filter == null
                ? appointmentRepository.findByPatientIdOrderByAppointmentDateDesc(patientId)
                : appointmentRepository.findByPatientIdAndStatusOrderByAppointmentDateDesc(patientId, filter);

        return appointments.stream()
                .map(this::toDetailResponse)
                .toList();
    }
    
    /**
     * Convert Appointment entity → AppointmentSlotResponse
     */
    private AppointmentSlotResponse toSlotResponse(Appointment appointment) {
        return AppointmentSlotResponse.builder()
                .appointmentId(appointment.getId())
                .slotNumber(appointment.getSlotNumber())
                .slotStartTime(appointment.getSlotStartTime())
                .slotEndTime(appointment.getSlotEndTime())
                .status(appointment.getStatus().toString())
                .patientName(appointment.getPatientName())
                .patientPhone(appointment.getPatientPhone())
                .notes(appointment.getNotes())
                .build();
    }

        private BasicUserInfo toBasicUser(User user) {
        if (user == null) {
            return null;
        }
        return BasicUserInfo.builder()
            .id(user.getId())
            .fullName(user.getProfile() != null && StringUtils.hasText(user.getProfile().getFullname())
                ? user.getProfile().getFullname()
                : user.getEmail())
            .phoneNumber(user.getProfile() != null && StringUtils.hasText(user.getProfile().getPhoneNumber())
                ? user.getProfile().getPhoneNumber()
                : user.getPhoneNumber())
            .email(user.getEmail())
            .avatarUrl(user.getProfile() != null ? user.getProfile().getAvatarUrl() : null)
            .build();
        }

        private AppointmentDetailResponse toDetailResponse(Appointment appointment) {
        return AppointmentDetailResponse.builder()
            .appointmentId(appointment.getId())
            .appointmentDate(appointment.getAppointmentDate())
            .slotNumber(appointment.getSlotNumber())
            .slotStartTime(appointment.getSlotStartTime())
            .slotEndTime(appointment.getSlotEndTime())
            .status(appointment.getStatus().toString())
            .doctor(toBasicUser(appointment.getDoctor()))
            .patient(toBasicUser(appointment.getPatient()))
            .patientName(appointment.getPatientName())
            .patientPhone(appointment.getPatientPhone())
            .notes(appointment.getNotes())
            .createdAt(appointment.getCreatedAt())
            .updatedAt(appointment.getUpdatedAt())
            .respondedAt(appointment.getRespondedAt())
            .build();
        }
}
