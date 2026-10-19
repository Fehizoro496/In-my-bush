-- Internal notes of the moderation team on a report, never shown to the reporter or the reported person.
CREATE TABLE report_notes (
    id UUID PRIMARY KEY,
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id),
    body VARCHAR(1000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX ix_report_notes_report ON report_notes(report_id, created_at);
