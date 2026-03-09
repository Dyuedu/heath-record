INSERT INTO roles (name)
VALUES ('admin')
    ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (name)
VALUES ('user')
    ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (name)
VALUES ('doctor')
ON CONFLICT (name) DO NOTHING;

-- INSERT INTO relatives (id, name, relationship, user_id)
-- VALUES
--     (gen_random_uuid(), 'Nguyễn Văn A', 'Dad', (SELECT id FROM users LIMIT 1)),
--     (gen_random_uuid(), 'Trần Thị B', 'Mom', (SELECT id FROM users LIMIT 1)),
--     (gen_random_uuid(), 'John Doe', 'Brother', (SELECT id FROM users LIMIT 1)),
--     (gen_random_uuid(), 'Bản thân', 'Me', (SELECT id FROM users LIMIT 1))
-- ON CONFLICT (id) DO NOTHING;