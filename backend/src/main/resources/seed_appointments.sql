-- ================================
-- SEED APPOINTMENTS (FIX VERSION)
-- ================================

-- ⚠️ Đảm bảo unique chỉ áp dụng cho slot đang hoạt động (AVAILABLE/PENDING/BOOKED)
DROP INDEX IF EXISTS unique_slot;
CREATE UNIQUE INDEX IF NOT EXISTS unique_active_slot 
ON appointments (doctor_user_id, appointment_date, slot_number)
WHERE status IN ('AVAILABLE','PENDING','BOOKED');

-- ================================
-- ===== HÔM NAY (CURRENT_DATE) ===
-- ================================

-- Slot 1: AVAILABLE
INSERT INTO appointments (
    doctor_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, created_at, updated_at, version
)
SELECT u.id, CURRENT_DATE, 1,
       '08:00'::time, '09:30'::time,
       'AVAILABLE', NOW(), NOW(), 0
FROM users u
WHERE u.email = 'doctor@health.com'
ON CONFLICT DO NOTHING;

-- Slot 2: PENDING
INSERT INTO appointments (
    doctor_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, patient_name, patient_phone, notes,
    created_at, updated_at, version
)
SELECT u.id, CURRENT_DATE, 2,
       '09:30'::time, '11:00'::time,
       'PENDING', 'Nguyễn Văn A', '0912345678', 'Khám tổng quát',
       NOW(), NOW(), 0
FROM users u
WHERE u.email = 'doctor@health.com'
ON CONFLICT DO NOTHING;

-- Slot 3: BOOKED
INSERT INTO appointments (
    doctor_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, patient_name, patient_phone, notes,
    created_at, updated_at, version
)
SELECT u.id, CURRENT_DATE, 3,
       '11:00'::time, '12:30'::time,
       'BOOKED', 'Trần Thị B', '0987654321', 'Khám định kỳ',
       NOW(), NOW(), 0
FROM users u
WHERE u.email = 'doctor@health.com'
ON CONFLICT DO NOTHING;

-- Slot 4 → 8: AVAILABLE
INSERT INTO appointments (
    doctor_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, created_at, updated_at, version
)
SELECT u.id, CURRENT_DATE, s.slot_num,
       s.start_time, s.end_time,
       'AVAILABLE', NOW(), NOW(), 0
FROM (
    SELECT 4, '14:00'::time, '15:30'::time UNION
    SELECT 5, '15:30'::time, '17:00'::time UNION
    SELECT 6, '16:00'::time, '17:30'::time UNION
    SELECT 7, '17:30'::time, '19:00'::time UNION
    SELECT 8, '18:00'::time, '19:30'::time
) AS s(slot_num, start_time, end_time)
CROSS JOIN users u
WHERE u.email = 'doctor@health.com'
ON CONFLICT DO NOTHING;

-- ================================
-- ===== NGÀY MAI (+1) ============
-- ================================

-- Slot 1: BOOKED
INSERT INTO appointments (
    doctor_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, patient_name, patient_phone, notes,
    created_at, updated_at, version
)
SELECT u.id, CURRENT_DATE + 1, 1,
       '08:00'::time, '09:30'::time,
       'BOOKED', 'Lê Quốc D', '0933221100', 'Tái khám',
       NOW(), NOW(), 0
FROM users u
WHERE u.email = 'doctor@health.com'
ON CONFLICT DO NOTHING;

-- Slot 2 → 8: AVAILABLE + 1 PENDING
INSERT INTO appointments (
    doctor_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, patient_name, patient_phone, notes,
    created_at, updated_at, version
)
SELECT u.id, CURRENT_DATE + 1, s.slot_num,
       s.start_time, s.end_time,
       s.status, s.patient_name, s.patient_phone, s.notes,
       NOW(), NOW(), 0
FROM (
    SELECT 2, '09:30'::time, '11:00'::time, 'AVAILABLE', NULL, NULL, NULL UNION
    SELECT 3, '11:00'::time, '12:30'::time, 'PENDING', 'Ngô Hữu E', '0944556677', 'Khám ban đầu' UNION
    SELECT 4, '14:00'::time, '15:30'::time, 'AVAILABLE', NULL, NULL, NULL UNION
    SELECT 5, '15:30'::time, '17:00'::time, 'AVAILABLE', NULL, NULL, NULL UNION
    SELECT 6, '16:00'::time, '17:30'::time, 'AVAILABLE', NULL, NULL, NULL UNION
    SELECT 7, '17:30'::time, '19:00'::time, 'AVAILABLE', NULL, NULL, NULL UNION
    SELECT 8, '18:00'::time, '19:30'::time, 'AVAILABLE', NULL, NULL, NULL
) AS s(slot_num, start_time, end_time, status, patient_name, patient_phone, notes)
CROSS JOIN users u
WHERE u.email = 'doctor@health.com'
ON CONFLICT DO NOTHING;

-- ================================
-- ===== NGÀY +2 ==================
-- ================================

-- All AVAILABLE
INSERT INTO appointments (
    doctor_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, created_at, updated_at, version
)
SELECT u.id, CURRENT_DATE + 2, s.slot_num,
       s.start_time, s.end_time,
       'AVAILABLE', NOW(), NOW(), 0
FROM (
    SELECT 1, '08:00'::time, '09:30'::time UNION
    SELECT 2, '09:30'::time, '11:00'::time UNION
    SELECT 3, '11:00'::time, '12:30'::time UNION
    SELECT 4, '14:00'::time, '15:30'::time UNION
    SELECT 5, '15:30'::time, '17:00'::time UNION
    SELECT 6, '16:00'::time, '17:30'::time UNION
    SELECT 7, '17:30'::time, '19:00'::time UNION
    SELECT 8, '18:00'::time, '19:30'::time
) AS s(slot_num, start_time, end_time)
CROSS JOIN users u
WHERE u.email = 'doctor@health.com'
ON CONFLICT DO NOTHING;

-- ================================
-- ===== TEST PATIENT BOOKINGS ====
-- ================================

-- Booking for vutrggiang@gmail.com
INSERT INTO appointments (
    doctor_user_id, patient_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, patient_name, patient_phone, notes,
    created_at, updated_at, version
)
SELECT d.id, p.id, CURRENT_DATE + 3, 1,
       '08:00'::time, '09:30'::time,
       'BOOKED', 'Vũ Trí Giang', '0901112223', 'Theo dõi hậu phẫu',
       NOW(), NOW(), 0
FROM users d
JOIN users p ON LOWER(d.email) = 'doctor@health.com' AND LOWER(p.email) = 'vutrggiang@gmail.com'
ON CONFLICT DO NOTHING;

-- Booking for vugiangtruong04@gmail.com
INSERT INTO appointments (
    doctor_user_id, patient_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, patient_name, patient_phone, notes,
    created_at, updated_at, version
)
SELECT d.id, p.id, CURRENT_DATE + 3, 2,
       '09:30'::time, '11:00'::time,
       'PENDING', 'Vũ Giang Trường', '0903334445', 'Khám tiêu hóa',
       NOW(), NOW(), 0
FROM users d
JOIN users p ON LOWER(d.email) = 'doctor@health.com' AND LOWER(p.email) = 'vugiangtruong04@gmail.com'
ON CONFLICT DO NOTHING;

-- Booking for thgmatngu@gmail.com
INSERT INTO appointments (
    doctor_user_id, patient_user_id, appointment_date, slot_number,
    slot_start_time, slot_end_time,
    status, patient_name, patient_phone, notes,
    created_at, updated_at, version
)
SELECT d.id, p.id, CURRENT_DATE + 4, 1,
       '08:00'::time, '09:30'::time,
       'BOOKED', 'Thắng Mặt Ngủ', '0917778889', 'Khám hô hấp',
       NOW(), NOW(), 0
FROM users d
JOIN users p ON LOWER(d.email) = 'doctor@health.com' AND LOWER(p.email) = 'thgmatngu@gmail.com'
ON CONFLICT DO NOTHING;