CREATE TABLE admin_audit_events (
    id UUID PRIMARY KEY,
    actor_id UUID NOT NULL REFERENCES users(id),
    action VARCHAR(80) NOT NULL,
    target_type VARCHAR(40) NOT NULL,
    target_id UUID,
    reason VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX admin_audit_created_idx ON admin_audit_events(created_at DESC);
CREATE INDEX admin_audit_target_idx ON admin_audit_events(target_type, target_id);

-- Shared by API instances: limits cannot be bypassed by changing instances.
CREATE TABLE auth_rate_limits (
    key_hash VARCHAR(64) PRIMARY KEY,
    attempts INTEGER NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX auth_rate_expiry_idx ON auth_rate_limits(expires_at);
