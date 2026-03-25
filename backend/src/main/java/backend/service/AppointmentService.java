package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.exception.AccessDeniedException;
import backend.model.*;
import backend.model.dto.request.AppointmentApprovalRequestDTO;
import backend.model.dto.request.CreateAppointmentRequestDTO;
import backend.model.dto.response.*;
import backend.repository.AppointmentRepository;
import backend.repository.UserRepository;
import backend.service.NotificationService;
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
    private final EmailService emailService;
    private final NotificationService notificationService;

    // Định nghĩa các time slot (8h - 21h)
    private static final int[] SLOT_START_HOURS = {8, 9, 11, 14, 15, 16, 17, 18};
    private static final int[] SLOT_START_MINUTES = {0, 30, 0, 0, 30, 0, 30, 0};
    private static final int SLOT_DURATION_MINUTES = 90;  // 1.5 giờ
        private static final List<AppointmentStatus> ACTIVE_SLOT_STATUSES = List.of(
            AppointmentStatus.AVAILABLE,
            AppointmentStatus.PENDING,
            AppointmentStatus.BOOKED
        );

    public AppointmentService(
            AppointmentRepository appointmentRepository,
            UserRepository userRepository,
            EmailService emailService,
            NotificationService notificationService) {
        this.appointmentRepository = appointmentRepository;
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.notificationService = notificationService;
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

    private LocalTime resolveSlotStartTime(int slotNumber) {
        return LocalTime.of(
                SLOT_START_HOURS[slotNumber - 1],
                SLOT_START_MINUTES[slotNumber - 1]
        );
    }

    private LocalTime resolveSlotEndTime(int slotNumber) {
        return resolveSlotStartTime(slotNumber).plusMinutes(SLOT_DURATION_MINUTES);
    }

    private Appointment buildAvailableSlot(User doctor, LocalDate date, int slotNumber) {
        return Appointment.builder()
                .doctor(doctor)
                .appointmentDate(date)
                .slotNumber(slotNumber)
                .slotStartTime(resolveSlotStartTime(slotNumber))
                .slotEndTime(resolveSlotEndTime(slotNumber))
                .status(AppointmentStatus.AVAILABLE)
                .build();
    }

    /**
     * Mở lại slot cho bác sĩ - KIỂM TRA TRÙNG LẶP TRƯỚC KHI TẠO MỚI
     */
    private void reopenSlot(Appointment source) {
        boolean activeSlotExists = appointmentRepository
            .existsByDoctorIdAndAppointmentDateAndSlotNumberAndStatusIn(
                source.getDoctor().getId(),
                source.getAppointmentDate(),
                source.getSlotNumber(),
                ACTIVE_SLOT_STATUSES
            );

        if (activeSlotExists) {
            log.info("Active slot already exists for doctor: {}, date: {}, slot: {}",
                source.getDoctor().getId(),
                source.getAppointmentDate(),
                source.getSlotNumber());
            return;
        }

        Appointment freshSlot = buildAvailableSlot(
            source.getDoctor(),
            source.getAppointmentDate(),
            source.getSlotNumber()
        );
        appointmentRepository.save(freshSlot);
        log.info("Created replacement available slot for doctor: {}, date: {}, slot: {}",
            source.getDoctor().getId(),
            source.getAppointmentDate(),
            source.getSlotNumber());
    }

    private void sendDecisionEmail(Appointment appointment, boolean approved, String reason) {
        try {
            if (appointment.getPatient() == null
                    || !StringUtils.hasText(appointment.getPatient().getEmail())) {
                log.warn("Cannot send email: Patient email is missing for appointment #{}", appointment.getId());
                return;
            }
            emailService.sendAppointmentDecisionEmail(
                    appointment.getPatient().getEmail(),
                    resolvePatientName(appointment.getPatient(), appointment.getPatientName()),
                    appointment.getDoctor().getProfile() != null
                            ? appointment.getDoctor().getProfile().getFullname()
                            : appointment.getDoctor().getEmail(),
                    appointment.getAppointmentDate(),
                    appointment.getSlotStartTime(),
                    appointment.getSlotEndTime(),
                    approved,
                    reason
            );
        } catch (Exception emailError) {
            log.warn("Không thể gửi email thông báo lịch khám #{}: {}",
                    appointment.getId(), emailError.getMessage());
        }
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
        if (request.getSlotNumber() < 1 || request.getSlotNumber() > 8) {
            throw new IllegalArgumentException("Slot không hợp lệ");
        }

        Optional<Appointment> existing = appointmentRepository
                .findTopByDoctorIdAndAppointmentDateAndSlotNumberOrderByUpdatedAtDesc(
                        doctorId,
                        request.getAppointmentDate(),
                        request.getSlotNumber()
                );

        Appointment slotRecord = existing.orElse(null);
        if (slotRecord != null) {
            if (slotRecord.getStatus() == AppointmentStatus.PENDING
                    || slotRecord.getStatus() == AppointmentStatus.BOOKED) {
                throw new IllegalArgumentException("Slot này không còn trống hoặc đã được đặt");
            }
            if (slotRecord.getStatus() != AppointmentStatus.AVAILABLE) {
                // Các trạng thái REJECTED / CANCELLED -> tạo slot mới để tái sử dụng
                slotRecord = buildAvailableSlot(
                        doctor,
                        request.getAppointmentDate(),
                        request.getSlotNumber()
                );
                slotRecord = appointmentRepository.save(slotRecord);
            }
        } else {
            slotRecord = appointmentRepository.save(
                    buildAvailableSlot(
                            doctor,
                            request.getAppointmentDate(),
                            request.getSlotNumber()
                    )
            );
        }

        slotRecord.setStatus(AppointmentStatus.PENDING);
        slotRecord.setDecisionReason(null);
        slotRecord.setRespondedAt(null);
        if (isPatient(actor)) {
            slotRecord.setPatient(actor);
            slotRecord.setPatientName(resolvePatientName(actor, request.getPatientName()));
            slotRecord.setPatientPhone(resolvePatientPhone(actor, request.getPatientPhone()));
        } else {
            slotRecord.setPatient(null);
            slotRecord.setPatientName(request.getPatientName());
            slotRecord.setPatientPhone(request.getPatientPhone());
        }
        slotRecord.setNotes(StringUtils.hasText(request.getNotes()) ? request.getNotes().trim() : null);
        slotRecord.setUpdatedAt(LocalDateTime.now());

        Appointment saved = appointmentRepository.save(slotRecord);

        // Send notification to doctor if patient created the request
        if (isPatient(actor)) {
            String patientName = saved.getPatientName();
            String doctorName = saved.getDoctor().getProfile() != null && StringUtils.hasText(saved.getDoctor().getProfile().getFullname())
                    ? saved.getDoctor().getProfile().getFullname()
                    : saved.getDoctor().getEmail();
            notificationService.createNotification(
                    saved.getDoctor().getId(),
                    "Lịch khám mới",
                    "Bệnh nhân " + patientName + " đã đặt lịch khám ngày " + saved.getAppointmentDate() + " slot " + saved.getSlotNumber() + ".",
                    doctorName,
                    null,
                    null
            );
        }

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

        AppointmentStatus currentStatus = appointment.getStatus();
        boolean approve = Boolean.TRUE.equals(request.getApprove());

        if (approve) {
            if (!AppointmentStatus.PENDING.equals(currentStatus)) {
                throw new IllegalArgumentException("Chỉ có thể duyệt lịch ở trạng thái chờ duyệt");
            }
            appointment.setStatus(AppointmentStatus.BOOKED);
            if (StringUtils.hasText(request.getNotes())) {
                appointment.setNotes(request.getNotes().trim());
            }
            appointment.setDecisionReason(null);
        } else {
            String reason = StringUtils.hasText(request.getNotes())
                    ? request.getNotes().trim()
                    : null;
            if (!StringUtils.hasText(reason)) {
                throw new IllegalArgumentException("Vui lòng nhập lý do từ chối hoặc hủy lịch");
            }

            if (AppointmentStatus.PENDING.equals(currentStatus)) {
                appointment.setStatus(AppointmentStatus.REJECTED);
            } else if (AppointmentStatus.BOOKED.equals(currentStatus)) {
                appointment.setStatus(AppointmentStatus.CANCELLED);
            } else {
                throw new IllegalArgumentException("Không thể từ chối/hủy lịch ở trạng thái hiện tại");
            }
            appointment.setDecisionReason(reason);
        }

        appointment.setRespondedAt(LocalDateTime.now());
        appointment.setUpdatedAt(LocalDateTime.now());

        Appointment saved = appointmentRepository.save(appointment);

        // Chỉ gọi reopenSlot khi từ chối (không approve)
        if (!approve) {
            reopenSlot(saved);
        }

        sendDecisionEmail(saved, approve, saved.getDecisionReason());

        // Send notification to patient if they have one
        if (saved.getPatient() != null) {
            String doctorName = saved.getDoctor().getProfile() != null && StringUtils.hasText(saved.getDoctor().getProfile().getFullname())
                    ? saved.getDoctor().getProfile().getFullname()
                    : saved.getDoctor().getEmail();
            String appointmentDateStr = saved.getAppointmentDate().toString();
            String slotTimeStr = saved.getSlotStartTime() + " - " + saved.getSlotEndTime();
            
            if (approve) {
                notificationService.createNotification(
                        saved.getPatient().getId(),
                        "Lịch khám đã được xác nhận",
                        "Bác sĩ " + doctorName + " đã xác nhận lịch khám của bạn vào ngày " + appointmentDateStr + " " + slotTimeStr + ".",
                        doctorName,
                        null,
                        null
                );
            } else {
                notificationService.createNotification(
                        saved.getPatient().getId(),
                        "Lịch khám đã bị từ chối",
                        "Lịch khám ngày " + appointmentDateStr + " " + slotTimeStr + " đã bị từ chối. Lý do: " + saved.getDecisionReason(),
                        doctorName,
                        null,
                        null
                );
            }
        }

        return AppointmentApprovalResponse.builder()
                .appointmentId(saved.getId())
                .status(saved.getStatus().toString())
                .message(approve ? "Đã chấp thuận lịch khám" : "Đã cập nhật lịch khám")
                .respondedAt(saved.getRespondedAt())
                .slotDetails(toSlotResponse(saved))
                .decisionReason(saved.getDecisionReason())
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
    public int getPendingAppointmentCount(UUID doctorId) {
        return appointmentRepository.countPendingAppointments(doctorId);
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
                .decisionReason(appointment.getDecisionReason())
                .createdAt(appointment.getCreatedAt())
                .updatedAt(appointment.getUpdatedAt())
                .respondedAt(appointment.getRespondedAt())
                .build();
    }
}