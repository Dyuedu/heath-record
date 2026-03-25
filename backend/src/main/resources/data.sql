INSERT INTO roles (name)
VALUES ('admin')
    ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (name)
VALUES ('user')
    ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (name)
VALUES ('doctor')
ON CONFLICT (name) DO NOTHING;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Seed 1 tài khoản bác sĩ mặc định
-- Email: doctor@health.com
-- Password: password123
INSERT INTO profile (
    id,
    fullname,
    gender,
    date_of_birth,
    phone_number,
    address,
    identity_number
)
SELECT
    gen_random_uuid(),
    'Dr. Demo',
    'Male',
    '1985-01-01',
    '0987654321',
    'Ha Noi',
    '001234567890'
WHERE NOT EXISTS (
    SELECT 1 FROM profile p WHERE p.identity_number = '001234567890'
);

INSERT INTO users (
    id,
    phone_number,
    password,
    email,
    created_at,
    status,
    profile_id,
    role_id
)
SELECT
    gen_random_uuid(),
    '0987654321',
    crypt('password123', gen_salt('bf', 10)),
    'doctor@health.com',
    NOW(),
    'ACTIVE',
    (SELECT p.id FROM profile p WHERE p.identity_number = '001234567890' LIMIT 1),
    (SELECT r.id FROM roles r WHERE LOWER(r.name) = 'doctor' LIMIT 1)
WHERE NOT EXISTS (
    SELECT 1 FROM users u WHERE LOWER(u.email) = 'doctor@health.com'
);

-- Đảm bảo tài khoản seed luôn có mật khẩu đúng sau mỗi lần init DB
UPDATE users
SET password = crypt('password123', gen_salt('bf', 10)),
    status = 'ACTIVE'
WHERE LOWER(email) = 'doctor@health.com';

INSERT INTO relatives (id, relationship, user_id, profile_id)
SELECT
    gen_random_uuid(),
    'Me',
    u.id,
    p.id
FROM users u
JOIN profile p ON p.id = u.profile_id
WHERE LOWER(u.email) = 'doctor@health.com'
AND NOT EXISTS (
    SELECT 1 FROM relatives r
    WHERE r.user_id = u.id
      AND r.profile_id = p.id
      AND LOWER(r.relationship) = 'me'
);

-- INSERT INTO relatives (id, name, relationship, user_id)
-- VALUES
--     (gen_random_uuid(), 'Nguyễn Văn A', 'Dad', (SELECT id FROM users LIMIT 1)),
--     (gen_random_uuid(), 'Trần Thị B', 'Mom', (SELECT id FROM users LIMIT 1)),
--     (gen_random_uuid(), 'John Doe', 'Brother', (SELECT id FROM users LIMIT 1)),
--     (gen_random_uuid(), 'Bản thân', 'Me', (SELECT id FROM users LIMIT 1))
-- ON CONFLICT (id) DO NOTHING;