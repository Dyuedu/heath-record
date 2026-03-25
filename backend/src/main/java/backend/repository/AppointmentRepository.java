package backend.repository;

import backend.model.Appointment;
import backend.model.AppointmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    /**
     * Lấy danh sách slot của bác sĩ trong một ngày
     */
    List<Appointment> findByDoctorIdAndAppointmentDate(UUID doctorId, LocalDate appointmentDate);

    /**
     * Lấy slot cụ thể của bác sĩ theo ngày và slot number
     */
    Optional<Appointment> findByDoctorIdAndAppointmentDateAndSlotNumber(
            UUID doctorId,
            LocalDate appointmentDate,
            int slotNumber
    );

    /**
     * Lấy danh sách slot của bác sĩ trong khoảng ngày
     */
    @Query("SELECT a FROM Appointment a WHERE a.doctor.id = :doctorId " +
            "AND a.appointmentDate BETWEEN :startDate AND :endDate " +
            "ORDER BY a.appointmentDate, a.slotNumber")
    List<Appointment> findDoctorScheduleByDateRange(
            @Param("doctorId") UUID doctorId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    /**
     * Kiểm tra xem slot đã tồn tại hay chưa (lấy bản ghi mới nhất)
     */
    Optional<Appointment> findTopByDoctorIdAndAppointmentDateAndSlotNumberOrderByUpdatedAtDesc(
            UUID doctorId,
            LocalDate appointmentDate,
            Integer slotNumber
    );

    /**
     * Kiểm tra sự tồn tại của slot
     */
    boolean existsByDoctorIdAndAppointmentDateAndSlotNumber(
            UUID doctorId,
            LocalDate appointmentDate,
            int slotNumber
    );

    boolean existsByDoctorIdAndAppointmentDateAndSlotNumberAndStatusIn(
            UUID doctorId,
            LocalDate appointmentDate,
            int slotNumber,
            List<AppointmentStatus> statuses
    );

    /**
     * Lấy danh sách lịch chờ duyệt của bác sĩ
     */
    List<Appointment> findByDoctorIdAndStatusOrderByAppointmentDateAsc(
            UUID doctorId,
            AppointmentStatus status
    );

    /**
     * Lấy danh sách lịch chờ duyệt của bác sĩ (theo ngày)
     */
    @Query("SELECT a FROM Appointment a WHERE a.doctor.id = :doctorId " +
            "AND a.status = :status ORDER BY a.appointmentDate ASC, a.slotNumber ASC")
    List<Appointment> findByDoctorIdAndStatusOrderByAppointmentDateAscSlotNumberAsc(
            @Param("doctorId") UUID doctorId,
            @Param("status") AppointmentStatus status
    );

    /**
     * Đếm số lịch chưa duyệt (PENDING) của bác sĩ
     */
    @Query("SELECT COUNT(a) FROM Appointment a WHERE a.doctor.id = :doctorId AND a.status = 'PENDING'")
    int countPendingAppointments(@Param("doctorId") UUID doctorId);

    /**
     * Lấy danh sách lịch của bệnh nhân
     */
    List<Appointment> findByPatientIdOrderByAppointmentDateDesc(UUID patientId);

    /**
     * Lấy danh sách lịch của bệnh nhân theo trạng thái
     */
    List<Appointment> findByPatientIdAndStatusOrderByAppointmentDateDesc(
            UUID patientId,
            AppointmentStatus status
    );

    /**
     * Lấy danh sách lịch của bác sĩ theo trạng thái
     */
    List<Appointment> findByDoctorIdAndStatusOrderByAppointmentDateDesc(
            UUID doctorId,
            AppointmentStatus status
    );

    /**
     * Lấy danh sách lịch của bác sĩ theo khoảng ngày và trạng thái
     */
    @Query("SELECT a FROM Appointment a WHERE a.doctor.id = :doctorId " +
            "AND a.appointmentDate BETWEEN :startDate AND :endDate " +
            "AND a.status = :status ORDER BY a.appointmentDate, a.slotNumber")
    List<Appointment> findDoctorScheduleByDateRangeAndStatus(
            @Param("doctorId") UUID doctorId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("status") AppointmentStatus status
    );
}