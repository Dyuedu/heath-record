CREATE TABLE IF NOT EXISTS profile_link_requests (
    id UUID PRIMARY KEY,
    requester_user_id UUID NOT NULL,
    owner_user_id UUID NOT NULL,
    target_profile_id UUID NOT NULL,
    request_type VARCHAR(32) NOT NULL,
    requested_relationship VARCHAR(255),
    note TEXT,
    status VARCHAR(32) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    responded_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_plr_requester_user FOREIGN KEY (requester_user_id) REFERENCES users(id),
    CONSTRAINT fk_plr_owner_user FOREIGN KEY (owner_user_id) REFERENCES users(id),
    CONSTRAINT fk_plr_target_profile FOREIGN KEY (target_profile_id) REFERENCES profile(id)
);

CREATE INDEX IF NOT EXISTS idx_plr_owner_status
    ON profile_link_requests (owner_user_id, status);

CREATE INDEX IF NOT EXISTS idx_plr_requester_status
    ON profile_link_requests (requester_user_id, status);

CREATE INDEX IF NOT EXISTS idx_plr_target_status
    ON profile_link_requests (target_profile_id, status);
