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
     * Kiểm tra xem slot đã tồn tại hay chưa
     */
    Optional<Appointment> findByDoctorIdAndAppointmentDateAndSlotNumber(
        UUID doctorId,
        LocalDate appointmentDate,
        Integer slotNumber
    );
    
    /**
     * Lấy danh sách lịch chờ duyệt của bác sĩ
     */
    List<Appointment> findByDoctorIdAndStatusOrderByAppointmentDateAsc(
        UUID doctorId,
        AppointmentStatus status
    );
    
    /**
     * Lấy danh sách lịch chưa duyệt (PENDING)
     */
    @Query("SELECT COUNT(a) FROM Appointment a WHERE a.doctor.id = :doctorId AND a.status = 'PENDING'")
    int countPendingAppointments(@Param("doctorId") UUID doctorId);

    List<Appointment> findByPatientIdOrderByAppointmentDateDesc(UUID patientId);

    List<Appointment> findByPatientIdAndStatusOrderByAppointmentDateDesc(
        UUID patientId,
        AppointmentStatus status
    );
}
