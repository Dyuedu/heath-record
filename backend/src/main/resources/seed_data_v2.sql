-- Script Khởi Tạo Dữ Liệu Tự Động (Seed Data) cho Ứng Dụng Y Tế
-- Constraints: Tên tự nhiên, Admin không profile, 2 admin, 5 doctor, 15 bệnh nhân (5 user, 10 relative)
-- Mỗi người có ít nhất 1 bệnh án, self relationship là 'ME'.
-- Định dạng UUID đúng chuẩn hệ thập lục phân (hex characters: 0-9, a-f)
-- Mật khẩu mặc định là 'password123' (hash BCrypt: $2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m)

-- 1. ROLES (Vai trò)
INSERT INTO roles (name) VALUES ('admin'), ('doctor'), ('user') ON CONFLICT (name) DO NOTHING;

-- 2. HOSPITALS (Bệnh viện)
INSERT INTO hospitals (name, is_active) VALUES 
('Bệnh viện Bạch Mai', true),
('Bệnh viện Đại học Y Dược TP.HCM', true),
('Bệnh viện Chợ Rẫy', true),
('Bệnh viện Nhi Trung Ương', true),
('Phòng khám Đa khoa Tâm Anh', true)
ON CONFLICT DO NOTHING;

-- 3. TAGS (Chuyên khoa/Dịch vụ) - Đa dạng Tags
INSERT INTO tags (name, description, is_active) VALUES 
('Tim Mạch', 'Chuyên khoa Nội Tim mạch', true),
('Nhi Khoa', 'Khám phòng bệnh trẻ em', true),
('Khám Tổng Quát', 'Khám sức khỏe định kỳ', true),
('Nội Khoa', 'Nội cơ xương khớp, tiêu hóa', true),
('Tai Mũi Họng', 'Chuyên khoa Mũi họng', true),
('Da Liễu', 'Bệnh lý ngoài da', true),
('Chấn Thương Chỉnh Hình', 'Khoa Cơ xương khớp', true),
('Ngoại Khoa', 'Phẫu thuật, xâm lấn', true),
('Mắt', 'Đo tật khúc xạ và bệnh lý mắt', true),
('Xét Nghiệm', 'Các loại kiểm tra hóa sinh huyết học', true),
('Siêu Âm', 'Chẩn đoán hình ảnh vùng bụng, thai nhi', true),
('Nội Soi', 'Chẩn đoán nội bộ ống tiêu hóa', true),
('Chụp X-Quang', 'Chẩn đoán hình ảnh xương, phổi', true),
('Thần Kinh', 'Bệnh lý não và cơ học', true),
('Hô Hấp', 'Bệnh lý phổi phế quản', true),
('Tiểu Đường', 'Kiểm soát đường huyết', true),
('Truyền Nhiễm', 'Bệnh lây nhiễm virus', true),
('Sản Phụ Khoa', 'Theo dõi sức khỏe sinh sản, mẹ và bé', true)
ON CONFLICT (name) DO NOTHING;

-- 4. PROFILES (Hồ sơ người dùng) -> 5 Doctors + 15 Patients = 20 profiles
-- DOCTORS (d0... valid hex)
INSERT INTO profile (id, fullname, identity_number, gender, date_of_birth, phone_number, address, blood_group, allergy, chronic_disease, clinical_notes) VALUES 
('d0000000-0000-0000-0000-000000000001', 'Hoàng Anh Quân', '001080123456', 'Nam', '1980-05-15', '0912111111', 'Hà Nội', 'A', NULL, NULL, 'Bác sĩ chuyên môn cao'),
('d0000000-0000-0000-0000-000000000002', 'Lê Ngọc Hân', '001085234567', 'Nữ', '1985-08-20', '0912222222', 'TP.HCM', 'O', 'Hải sản', NULL, NULL),
('d0000000-0000-0000-0000-000000000003', 'Trần Minh Tuấn', '001078345678', 'Nam', '1978-02-10', '0912333333', 'Đà Nẵng', 'B', NULL, 'Huyết áp', 'Theo dõi định kỳ'),
('d0000000-0000-0000-0000-000000000004', 'Phạm Xuân Trường', '001090456789', 'Nam', '1990-11-05', '0912444444', 'Hải Phòng', 'O', NULL, NULL, NULL),
('d0000000-0000-0000-0000-000000000005', 'Vũ Bảo Trâm', '001088567890', 'Nữ', '1988-06-30', '0912555555', 'Cần Thơ', 'AB', 'Phấn hoa', NULL, NULL)
ON CONFLICT DO NOTHING;

-- PATIENTS (e0... valid hex)
INSERT INTO profile (id, fullname, identity_number, gender, date_of_birth, phone_number, address, blood_group, allergy, chronic_disease, clinical_notes) VALUES 
('e0000000-0000-0000-0000-000000000001', 'Nguyễn Văn Bình', '002090123123', 'Nam', '1990-01-01', '0981111111', 'Ba Đình, Hà Nội', 'O', 'Đậu phộng, hải sản', 'Tiểu đường tuýp 2', 'Bệnh nhân có tiền sử sốc phản vệ nhẹ'),
('e0000000-0000-0000-0000-000000000002', 'Trần Thị Đào', '002095234234', 'Nữ', '1995-02-02', '0982222222', 'Quận 1, TP.HCM', 'A', NULL, NULL, 'Sức khỏe bình thường'),
('e0000000-0000-0000-0000-000000000003', 'Lê Thanh Hoàng', '002088345345', 'Nam', '1988-03-03', '0983333333', 'Cầu Giấy, Hà Nội', 'B', 'Penicillin', 'Đau dạ dày', 'Thường xuyên ợ chua'),
('e0000000-0000-0000-0000-000000000004', 'Phạm Tuấn Anh', '002092456456', 'Nam', '1992-04-04', '0984444444', 'Thanh Khê, Đà Nẵng', 'O', NULL, 'Gout', 'Acid uric cao, cần kiêng đạm'),
('e0000000-0000-0000-0000-000000000005', 'Đặng Bích Vân', '002098567567', 'Nữ', '1998-05-05', '0985555555', 'Ninh Kiều, Cần Thơ', 'AB', 'Dị ứng thời tiết', 'Đau nửa đầu Migraine', NULL),
('e0000000-0000-0000-0000-000000000006', 'Nguyễn Văn An', null, 'Nam', '1960-06-06', null, 'Ba Đình, Hà Nội', 'O', NULL, 'Cao huyết áp', 'Uống thuốc huyết áp hàng ngày'),
('e0000000-0000-0000-0000-000000000007', 'Nguyễn Thị Hoa', null, 'Nữ', '1965-07-07', null, 'Ba Đình, Hà Nội', NULL, 'Lông chó mèo', 'Viêm khớp xương', 'Khớp gối hay đau nhức khi trời lạnh'),
('e0000000-0000-0000-0000-000000000008', 'Trần Hùng', null, 'Nam', '1962-08-08', null, 'Quận 1, TP.HCM', 'A', NULL, 'Trĩ nội', NULL),
('e0000000-0000-0000-0000-000000000009', 'Hoàng Khôi', null, 'Nam', '1993-09-09', null, 'Quận 1, TP.HCM', 'B', 'Mực', 'Viêm loét dạ dày HP', 'Đang trong phác đồ diệt HP'),
('e0000000-0000-0000-0000-000000000010', 'Lê Thanh Tân', null, 'Nam', '2015-10-10', null, 'Cầu Giấy, Hà Nội', 'A', 'Sữa bò', 'Suy dinh dưỡng nhẹ', 'Đang uống bổ sung kẽm và vi chất'),
('e0000000-0000-0000-0000-000000000011', 'Vũ Thị Lý', null, 'Nữ', '1970-11-11', null, 'Thanh Khê, Đà Nẵng', NULL, NULL, 'Rối loạn tiền đình', 'Hay chóng mặt, buồn nôn'),
('e0000000-0000-0000-0000-000000000012', 'Đinh Văn Phong', null, 'Nam', '1995-12-12', null, 'Ninh Kiều, Cần Thơ', 'AB', NULL, 'Gan nhiễm mỡ độ 1', 'Men gan hay tăng cao'),
('e0000000-0000-0000-0000-000000000013', 'Đặng Ngọc Yến', null, 'Nữ', '2020-01-13', null, 'Ninh Kiều, Cần Thơ', 'A', NULL, NULL, 'Mới bị sốt siêu vi'),
('e0000000-0000-0000-0000-000000000014', 'Lê Thị Bảy', null, 'Nữ', '1940-02-14', null, 'Hà Nội', 'O', 'Thuốc cản quang', 'Đục thủy tinh thể, suy tim độ 2', 'Bệnh nhân lớn tuổi, cẩn thận khi kê thuốc cản quang'),
('e0000000-0000-0000-0000-000000000015', 'Nguyễn Hoàng Lâm', null, 'Nam', '2022-03-15', null, 'Quận 1, TP.HCM', 'B', NULL, NULL, 'Đang mọc răng')
ON CONFLICT DO NOTHING;

-- 5. USERS (Tài khoản)
INSERT INTO users (id, phone_number, email, password, status, created_at, role_id, profile_id) VALUES 
('a0000000-0000-0000-0000-000000000001', '0111000001', 'admin1@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'admin'), NULL),
('a0000000-0000-0000-0000-000000000002', '0111000002', 'admin2@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'admin'), NULL),

('b0000000-0000-0000-0000-000000000001', '0912111111', 'doc1@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'doctor'), 'd0000000-0000-0000-0000-000000000001'),
('b0000000-0000-0000-0000-000000000002', '0912222222', 'doc2@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'doctor'), 'd0000000-0000-0000-0000-000000000002'),
('b0000000-0000-0000-0000-000000000003', '0912333333', 'doc3@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'doctor'), 'd0000000-0000-0000-0000-000000000003'),
('b0000000-0000-0000-0000-000000000004', '0912444444', 'doc4@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'doctor'), 'd0000000-0000-0000-0000-000000000004'),
('b0000000-0000-0000-0000-000000000005', '0912555555', 'doc5@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'doctor'), 'd0000000-0000-0000-0000-000000000005'),

('c0000000-0000-0000-0000-000000000001', '0981111111', 'pat1@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'user'), 'e0000000-0000-0000-0000-000000000001'),
('c0000000-0000-0000-0000-000000000002', '0982222222', 'pat2@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'user'), 'e0000000-0000-0000-0000-000000000002'),
('c0000000-0000-0000-0000-000000000003', '0983333333', 'pat3@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'user'), 'e0000000-0000-0000-0000-000000000003'),
('c0000000-0000-0000-0000-000000000004', '0984444444', 'pat4@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'user'), 'e0000000-0000-0000-0000-000000000004'),
('c0000000-0000-0000-0000-000000000005', '0985555555', 'pat5@health.com', '$2a$10$qWP9e7wgpwN/XJUr2tf5bO4FeWgv6O41kwbKi3FsYLLYn26oKus3m', 'ACTIVE', CURRENT_TIMESTAMP, (SELECT id FROM roles WHERE name = 'user'), 'e0000000-0000-0000-0000-000000000005')
ON CONFLICT DO NOTHING;

-- 6. RELATIVES (Liên kết User -> Profile: Self là ME)
INSERT INTO relatives (id, relationship, user_id, profile_id) VALUES 
('f0000000-0000-0000-0001-000000000001', 'ME', 'b0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001'),
('f0000000-0000-0000-0001-000000000002', 'ME', 'b0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002'),
('f0000000-0000-0000-0001-000000000003', 'ME', 'b0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000003'),
('f0000000-0000-0000-0001-000000000004', 'ME', 'b0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000004'),
('f0000000-0000-0000-0001-000000000005', 'ME', 'b0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000005'),
('f0000000-0000-0000-0002-000000000001', 'ME', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001'),
('f0000000-0000-0000-0002-000000000002', 'ME', 'c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002'),
('f0000000-0000-0000-0002-000000000003', 'ME', 'c0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000003'),
('f0000000-0000-0000-0002-000000000004', 'ME', 'c0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000004'),
('f0000000-0000-0000-0002-000000000005', 'ME', 'c0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000005'),

(gen_random_uuid(), 'Bố', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000006'),
(gen_random_uuid(), 'Mẹ', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000007'),
(gen_random_uuid(), 'Khác', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000014'),
(gen_random_uuid(), 'Bố', 'c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000008'),
(gen_random_uuid(), 'Chồng', 'c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000009'),
(gen_random_uuid(), 'Khác', 'c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000015'),
(gen_random_uuid(), 'Con', 'c0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000010'),
(gen_random_uuid(), 'Mẹ', 'c0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000011'),
(gen_random_uuid(), 'Chồng', 'c0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000012'),
(gen_random_uuid(), 'Con', 'c0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000013')
ON CONFLICT DO NOTHING;

-- 7. ENCOUNTERS (Initialize without tags, will compute dynamically later)
INSERT INTO encounters (id, title, tag, doctor_user_id, profile_id, hospital_id, datetime_start, datetime_end) VALUES 
-- FIRST ROUND (Encounters 1..15)
(1, 'Khám sức khỏe tổng quát (L1)', NULL, 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 1, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '1 hour'),
(2, 'Khám tổng quát, tầm soát tiểu đường (L1)', NULL, 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 2, CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '25 days' + INTERVAL '30 minutes'),
(3, 'Tư vấn phẫu thuật khớp (L1)', NULL, 'b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000003', 3, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP - INTERVAL '20 days' + INTERVAL '45 minutes'),
(4, 'Khám đau dạ dày (L1)', NULL, 'b0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000004', 1, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '40 minutes'),
(5, 'Khám thai định kỳ 12 tuần (L1)', NULL, 'b0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000005', 4, CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '20 minutes'),
(6, 'Cao huyết áp ở người già (L1)', NULL, 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000006', 1, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '50 minutes'),
(7, 'Đau nhức xương khớp (L1)', NULL, 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000007', 2, CURRENT_TIMESTAMP - INTERVAL '6 days', CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '30 minutes'),
(8, 'Khám trĩ nội (L1)', NULL, 'b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000008', 3, CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '35 minutes'),
(9, 'Viêm loét dạ dày HP (L1)', NULL, 'b0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000009', 1, CURRENT_TIMESTAMP - INTERVAL '8 days', CURRENT_TIMESTAMP - INTERVAL '8 days' + INTERVAL '25 minutes'),
(10, 'Sốt xuất huyết ở trẻ (L1)', NULL, 'b0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000010', 4, CURRENT_TIMESTAMP - INTERVAL '9 days', CURRENT_TIMESTAMP - INTERVAL '9 days' + INTERVAL '45 minutes'),
(11, 'Khám đau đầu thường xuyên (L1)', NULL, 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000011', 2, CURRENT_TIMESTAMP - INTERVAL '11 days', CURRENT_TIMESTAMP - INTERVAL '11 days' + INTERVAL '30 minutes'),
(12, 'Theo dõi viêm gan (L1)', NULL, 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000012', 3, CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '30 minutes'),
(13, 'Sốt siêu vi ở trẻ 2 tuổi (L1)', NULL, 'b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000013', 4, CURRENT_TIMESTAMP - INTERVAL '13 days', CURRENT_TIMESTAMP - INTERVAL '13 days' + INTERVAL '20 minutes'),
(14, 'Khám mắt, đục thủy tinh thể (L1)', NULL, 'b0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000014', 1, CURRENT_TIMESTAMP - INTERVAL '14 days', CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '40 minutes'),
(15, 'Sởi Nhi Đồng (L1)', NULL, 'b0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000015', 4, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '30 minutes'),

-- SECOND ROUND (Encounters 16..30)
(16, 'Tái khám tổng quát (L2)', NULL, 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 1, CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '1 hour'),
(17, 'Theo dõi đường huyết (L2)', NULL, 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 2, CURRENT_TIMESTAMP - INTERVAL '6 days', CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '30 minutes'),
(18, 'Xét nghiệm trước mổ (L2)', NULL, 'b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000003', 3, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '45 minutes'),
(19, 'Tái khám dạ dày (L2)', NULL, 'b0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000004', 1, CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '40 minutes'),
(20, 'Nội soi họng lần 2 (L2)', NULL, 'b0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000005', 4, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '20 minutes'),
(21, 'Lấy thuốc huyết áp (L2)', NULL, 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000006', 1, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '15 minutes'),
(22, 'Phục hồi chức năng (L2)', NULL, 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000007', 2, CURRENT_TIMESTAMP - INTERVAL '1 days', CURRENT_TIMESTAMP - INTERVAL '1 days' + INTERVAL '60 minutes'),
(23, 'Tái khám hậu phẫu trĩ (L2)', NULL, 'b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000008', 3, CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '6 hours' + INTERVAL '30 minutes'),
(24, 'Chữa loét dạ dày (L2)', NULL, 'b0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000009', 1, CURRENT_TIMESTAMP - INTERVAL '5 hours', CURRENT_TIMESTAMP - INTERVAL '5 hours' + INTERVAL '40 minutes'),
(25, 'Cắt sốt xuất huyết (L2)', NULL, 'b0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000010', 4, CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '4 hours' + INTERVAL '25 minutes'),
(26, 'Kiểm tra tiền đình (L2)', NULL, 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000011', 2, CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '3 hours' + INTERVAL '35 minutes'),
(27, 'Tái khám gan mỡ (L2)', NULL, 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000012', 3, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours' + INTERVAL '30 minutes'),
(28, 'Tiêm phòng bạch hầu (L2)', NULL, 'b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000013', 4, CURRENT_TIMESTAMP - INTERVAL '1 hours', CURRENT_TIMESTAMP - INTERVAL '1 hours' + INTERVAL '10 minutes'),
(29, 'Đo kính cận 2 độ (L2)', NULL, 'b0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000014', 1, CURRENT_TIMESTAMP - INTERVAL '45 minutes', CURRENT_TIMESTAMP - INTERVAL '45 minutes' + INTERVAL '20 minutes'),
(30, 'Tái khám sau Sởi (L2)', NULL, 'b0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000015', 4, CURRENT_TIMESTAMP - INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '30 minutes' + INTERVAL '15 minutes')
ON CONFLICT DO NOTHING;

-- Cập nhật relative_id cho encounters
UPDATE encounters 
SET relative_id = (SELECT r.id FROM relatives r WHERE r.profile_id = encounters.profile_id LIMIT 1)
WHERE relative_id IS NULL;


-- 8. DIAGNOSTIC RECORDS (Với nhiều tags được phân tách bằng dấu phẩy)
INSERT INTO diagnostic_records (id, category, tag, type, doctor, data, encounter_id, profile_id, hospital_id) VALUES 
(1, 'Huyết áp & Cân nặng (L1)', 'Khám Tổng Quát, Xét Nghiệm', 'INITIAL', 'Hoàng Anh Quân', 'Huyết áp bình thường', 1, 'e0000000-0000-0000-0000-000000000001', 1),
(2, 'Sinh hóa máu (L1)', 'Khám Tổng Quát, Tiểu Đường, Xét Nghiệm', 'INITIAL', 'Lê Ngọc Hân', 'Bình thường', 2, 'e0000000-0000-0000-0000-000000000002', 2),
(3, 'Chỉ số viêm (L1)', 'Ngoại Khoa, Chụp X-Quang', 'INITIAL', 'Trần Minh Tuấn', 'Tăng nhẹ', 3, 'e0000000-0000-0000-0000-000000000003', 3),
(4, 'Nội soi dạ dày (L1)', 'Nội Khoa, Nội Soi, Tiêu Hóa', 'INITIAL', 'Phạm Xuân Trường', 'Viêm hang vị', 4, 'e0000000-0000-0000-0000-000000000004', 1),
(5, 'Siêu âm thai nhi 4D (L1)', 'Sản Phụ Khoa, Siêu Âm', 'INITIAL', 'Vũ Bảo Trâm', 'Thai nhi 12 tuần phát triển tốt, tim thai 140l/p', 5, 'e0000000-0000-0000-0000-000000000005', 4),
(6, 'Đo điện tâm đồ (L1)', 'Tim Mạch, Khám Tổng Quát', 'INITIAL', 'Hoàng Anh Quân', 'Nhịp tim nhanh', 6, 'e0000000-0000-0000-0000-000000000006', 1),
(7, 'Chụp XQ khớp (L1)', 'Chấn Thương Chỉnh Hình, Chụp X-Quang', 'INITIAL', 'Lê Ngọc Hân', 'Thoái hóa khớp gối', 7, 'e0000000-0000-0000-0000-000000000007', 2),
(8, 'Nội soi trực tràng (L1)', 'Nội Khoa, Nội Soi, Tiêu Hóa', 'INITIAL', 'Trần Minh Tuấn', 'Trĩ nội độ 2', 8, 'e0000000-0000-0000-0000-000000000008', 3),
(9, 'Xét nghiệm HP (L1)', 'Nội Khoa, Xét Nghiệm', 'INITIAL', 'Phạm Xuân Trường', 'Dương tính mờ', 9, 'e0000000-0000-0000-0000-000000000009', 1),
(10, 'Sinh hóa máu bé (L1)', 'Nhi Khoa, Xét Nghiệm', 'INITIAL', 'Vũ Bảo Trâm', 'Thiếu sắt', 10, 'e0000000-0000-0000-0000-000000000010', 4),
(11, 'Khám sàn chậu (L1)', 'Khám Tổng Quát, Siêu Âm', 'INITIAL', 'Hoàng Anh Quân', 'Phù hợp tuổi già', 11, 'e0000000-0000-0000-0000-000000000011', 2),
(12, 'Men gan (L1)', 'Nội Khoa, Xét Nghiệm', 'INITIAL', 'Lê Ngọc Hân', 'Men gan cao gấp đôi', 12, 'e0000000-0000-0000-0000-000000000012', 3),
(13, 'Đo Nhiệt độ (L1)', 'Nhi Khoa, Khám Tổng Quát', 'INITIAL', 'Trần Minh Tuấn', 'Sốt 39.5 độ', 13, 'e0000000-0000-0000-0000-000000000013', 4),
(14, 'Đo nhãn áp (L1)', 'Mắt, Khám Tổng Quát', 'INITIAL', 'Phạm Xuân Trường', 'Nhãn áp tăng', 14, 'e0000000-0000-0000-0000-000000000014', 1),
(15, 'Kiểm tra ban (L1)', 'Nhi Khoa, Da Liễu', 'INITIAL', 'Vũ Bảo Trâm', 'Nổi ban dạng sởi', 15, 'e0000000-0000-0000-0000-000000000015', 4),

(16, 'Đo BMI (L2)', 'Khám Tổng Quát', 'INITIAL', 'Hoàng Anh Quân', 'BMI 22.4', 16, 'e0000000-0000-0000-0000-000000000001', 1),
(17, 'Đo đường huyết (L2)', 'Khám Tổng Quát, Tiểu Đường', 'INITIAL', 'Lê Ngọc Hân', '6.0 mmol/L', 17, 'e0000000-0000-0000-0000-000000000002', 2),
(18, 'XQuang Đầu (L2)', 'Ngoại Khoa, Chụp X-Quang, Thần Kinh', 'INITIAL', 'Trần Minh Tuấn', 'Chưa có dấu hiệu tai biến', 18, 'e0000000-0000-0000-0000-000000000003', 3),
(19, 'Test HP Hơi thở (L2)', 'Nội Khoa, Xét Nghiệm', 'INITIAL', 'Phạm Xuân Trường', 'Giảm lượng khuẩn HP', 19, 'e0000000-0000-0000-0000-000000000004', 1),
(20, 'Nội soi Vòm họng (L2)', 'Tai Mũi Họng, Nội Soi, Hô Hấp', 'INITIAL', 'Vũ Bảo Trâm', 'Bớt viêm', 20, 'e0000000-0000-0000-0000-000000000005', 4),
(21, 'Tâm đồ 24h (L2)', 'Tim Mạch', 'INITIAL', 'Hoàng Anh Quân', 'Khả quan, nhịp tim ổn định', 21, 'e0000000-0000-0000-0000-000000000006', 1),
(22, 'Siêu âm dịch khớp (L2)', 'Chấn Thương Chỉnh Hình, Siêu Âm', 'INITIAL', 'Lê Ngọc Hân', 'Hết dịch khớp', 22, 'e0000000-0000-0000-0000-000000000007', 2),
(23, 'Khám ngoài (L2)', 'Nội Khoa', 'INITIAL', 'Trần Minh Tuấn', 'Trĩ giảm sưng', 23, 'e0000000-0000-0000-0000-000000000008', 3),
(24, 'Khám dạ dày (L2)', 'Nội Khoa', 'INITIAL', 'Phạm Xuân Trường', 'Hết loét vi thể', 24, 'e0000000-0000-0000-0000-000000000009', 1),
(25, 'Lấy máu cục bộ (L2)', 'Nhi Khoa, Xét Nghiệm', 'INITIAL', 'Vũ Bảo Trâm', 'Tiểu cầu tăng lại mức an toàn', 25, 'e0000000-0000-0000-0000-000000000010', 4),
(26, 'Thử thính giác (L2)', 'Khám Tổng Quát, Thần Kinh', 'INITIAL', 'Hoàng Anh Quân', 'Thính giác kém nhẹ', 26, 'e0000000-0000-0000-0000-000000000011', 2),
(27, 'Xét nghiệm máu (L2)', 'Nội Khoa, Xét Nghiệm', 'INITIAL', 'Lê Ngọc Hân', 'Men gan 40U/L (ổn định)', 27, 'e0000000-0000-0000-0000-000000000012', 3),
(28, 'Nhịp tim & phổi (L2)', 'Nhi Khoa, Hô Hấp', 'INITIAL', 'Trần Minh Tuấn', 'Tiếng phổi trong, hết ho', 28, 'e0000000-0000-0000-0000-000000000013', 4),
(29, 'Siêu âm mắt (L2)', 'Mắt, Siêu Âm', 'INITIAL', 'Phạm Xuân Trường', 'Giảm đục rìa', 29, 'e0000000-0000-0000-0000-000000000014', 1),
(30, 'Kê đơn Vitamin (L2)', 'Nhi Khoa, Da Liễu', 'INITIAL', 'Vũ Bảo Trâm', 'Hết ban, da lột vảy nhẹ', 30, 'e0000000-0000-0000-0000-000000000015', 4)
ON CONFLICT DO NOTHING;

UPDATE diagnostic_records 
SET relative_id = (SELECT r.id FROM relatives r WHERE r.profile_id = diagnostic_records.profile_id LIMIT 1)
WHERE relative_id IS NULL;


-- 9. DYNAMIC MANY-TO-MANY TAGS MAPPING
-- Insert into diagnostic_record_tags by parsing diagnostic_records.tag
INSERT INTO diagnostic_record_tags (diagnostic_record_id, tag_id)
SELECT d.id, t.id
FROM diagnostic_records d
JOIN tags t ON TRIM(t.name) = ANY(string_to_array(d.tag, ', '));

-- Insert into encounter_tags directly from the diagnostic_record_tags linkage
INSERT INTO encounter_tags (encounter_id, tag_id)
SELECT DISTINCT d.encounter_id, dt.tag_id
FROM diagnostic_records d
JOIN diagnostic_record_tags dt ON d.id = dt.diagnostic_record_id;

-- Update encounters.tag using aggregated distinct tags
UPDATE encounters e
SET tag = (
    SELECT string_agg(DISTINCT t.name, ', ')
    FROM encounter_tags et
    JOIN tags t ON et.tag_id = t.id
    WHERE et.encounter_id = e.id
)
WHERE EXISTS (
    SELECT 1 FROM encounter_tags et2 WHERE et2.encounter_id = e.id
);


-- 10. ATTACHMENTS (File đính kèm kết quả khám)
INSERT INTO attachments (public_id, image_url, diagnostic_record_id) VALUES
('fetal_ultrasound', 'https://res.cloudinary.com/dtl1676rh/image/upload/v1774476848/health-record/avatars/user_c0000000-0000-0000-0000-000000000001.jpg', 5),
('knee_xray', 'https://res.cloudinary.com/dtl1676rh/image/upload/v1774478300/health-record/uploads/record_2360841d-6c13-4ae0-9863-288ef926d8da.jpg', 7),
('stomach_endoscopy', 'https://res.cloudinary.com/dtl1676rh/image/upload/v1774478489/health-record/uploads/record_acaca247-62e6-4955-97d0-f64d1fde2f66.jpg', 4)
ON CONFLICT DO NOTHING;


-- Reset sequence
SELECT setval('roles_id_seq', (SELECT COALESCE(MAX(id), 1) FROM roles));
SELECT setval('hospitals_id_seq', (SELECT COALESCE(MAX(id), 1) FROM hospitals));
SELECT setval('tags_id_seq', (SELECT COALESCE(MAX(id), 1) FROM tags));
SELECT setval('encounters_id_seq', (SELECT COALESCE(MAX(id), 1) FROM encounters));
SELECT setval('diagnostic_records_id_seq', (SELECT COALESCE(MAX(id), 1) FROM diagnostic_records));
SELECT setval('appointments_id_seq', (SELECT COALESCE(MAX(id), 1) FROM appointments));
SELECT setval('attachments_id_seq', (SELECT COALESCE(MAX(id), 1) FROM attachments));

