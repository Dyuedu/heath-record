-- PostgreSQL Database Seeding Script for Health Record System
-- This script uses gen_random_uuid() and can be run manually to seed your database.

-- 1. Insert Roles
-- INSERT INTO roles (id, name) VALUES (1, 'ADMIN') ON CONFLICT (name) DO NOTHING;
-- INSERT INTO roles (id, name) VALUES (2, 'DOCTOR') ON CONFLICT (name) DO NOTHING;
-- INSERT INTO roles (id, name) VALUES (3, 'USER') ON CONFLICT (name) DO NOTHING;

-- 2. Insert Hospitals
INSERT INTO hospitals (id, name) VALUES (1, 'Bệnh viện Bạch Mai') ON CONFLICT DO NOTHING;
INSERT INTO hospitals (id, name) VALUES (2, 'Bệnh viện Chợ Rẫy') ON CONFLICT DO NOTHING;
INSERT INTO hospitals (id, name) VALUES (3, 'Bệnh viện Vinmec') ON CONFLICT DO NOTHING;
INSERT INTO hospitals (id, name) VALUES (4, 'Bệnh viện Việt Đức') ON CONFLICT DO NOTHING;
INSERT INTO hospitals (id, name) VALUES (5, 'Bệnh viện Đại học Y Dược') ON CONFLICT DO NOTHING;

-- 3. Insert Tags
INSERT INTO tags (id, name, description) VALUES (1, 'Cardiology', 'Tim mạch') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (2, 'Blood Test', 'Xét nghiệm máu') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (3, 'X-Ray', 'Chụp X-Quang') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (4, 'Pediatrics', 'Nhi khoa') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (5, 'Neurology', 'Thần kinh') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (6, 'Dermatology', 'Da liễu') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (7, 'Orthopedics', 'Chấn thương chỉnh hình') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (8, 'Ophthalmology', 'Mắt') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (9, 'Dental', 'Nha khoa') ON CONFLICT (name) DO NOTHING;
INSERT INTO tags (id, name, description) VALUES (10, 'General', 'Khám tổng quát') ON CONFLICT (name) DO NOTHING;

-- 4. Create Profiles
-- Doctor Profile
INSERT INTO profile (id, fullname, gender, date_of_birth, address) 
VALUES (gen_random_uuid(), 'Dr. John Smith', 'Male', '1980-05-15', '123 Health St') ON CONFLICT (id) DO NOTHING;

-- Patient Profile
INSERT INTO profile (id, fullname, gender, date_of_birth, address) 
VALUES (gen_random_uuid(), 'Alice Johnson', 'Female', '1990-10-20', '456 User Ave') ON CONFLICT (id) DO NOTHING;

-- 5. Create Users
-- Password is 'password123' hashed: $2a$10$X.a/Q9E/zR.M/YQW99kC.ev3L2N6K2X2G1E1/I1v/x2tBf8U1o6lC
-- Associate Doctor User with Doctor Profile
INSERT INTO users (id, phone_number, email, password, profile_id, role_id) 
SELECT gen_random_uuid(), '0987654321', 'doctor@health.com', '$2a$10$X.a/Q9E/zR.M/YQW99kC.ev3L2N6K2X2G1E1/I1v/x2tBf8U1o6lC', id, 2 
FROM profile WHERE fullname = 'Dr. John Smith' ON CONFLICT (id) DO NOTHING;

-- 6. Create Medical Records (Encounters)
-- Use profile_id (Patient) and doctor_user_id (Doctor)
INSERT INTO encounters (id, title, tag, note, doctor_user_id, hospital_id, datetime_start, profile_id) 
SELECT 1, 'Khám sức khỏe tổng quát', 'Khám Tổng Quát', 'Bệnh nhân khỏe mạnh', 
       (SELECT id FROM users WHERE email = 'doctor@health.com'), 
       1, CURRENT_TIMESTAMP, 
       (SELECT id FROM profile WHERE fullname = 'Alice Johnson')
ON CONFLICT (id) DO NOTHING;

-- 7. Create Diagnostic Records
INSERT INTO diagnostic_records (id, category, tag, data, doctor, profile_id, hospital_id, encounter_id)
SELECT 1, 'Chỉ số sinh tồn', 'General', 'Huyết áp: 120/80 mmHg, Cân nặng: 55kg', 'Dr. John Smith', 
       (SELECT id FROM profile WHERE fullname = 'Alice Johnson'), 
       1, 1
ON CONFLICT (id) DO NOTHING;

-- Postgres Sequence resets
SELECT setval('roles_id_seq', (SELECT MAX(id) FROM roles));
SELECT setval('hospitals_id_seq', (SELECT MAX(id) FROM hospitals));
SELECT setval('tags_id_seq', (SELECT MAX(id) FROM tags));
SELECT setval('encounters_id_seq', (SELECT MAX(id) FROM encounters));
SELECT setval('diagnostic_records_id_seq', (SELECT MAX(id) FROM diagnostic_records));
