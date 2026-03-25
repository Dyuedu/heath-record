package backend.model;

public enum AppointmentStatus {
    AVAILABLE,      // Slot còn trống (default)
    PENDING,        // Chờ duyệt từ bác sĩ
    BOOKED,         // Đã đặt lịch (duyệt xong)
    REJECTED,       // Bác sĩ từ chối
    CANCELLED       // Bác sĩ/bệnh nhân hủy
}
