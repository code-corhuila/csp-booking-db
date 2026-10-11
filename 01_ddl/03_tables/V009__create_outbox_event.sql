-- Transactional outbox of the booking domain (ADR-014, ADR-019, Norma 5.3.11). The API
-- inserts the row in the same transaction as the change; csp-worker only reads it and
-- keeps its publication state in its own schema, so this table has no processed_at.
CREATE TABLE booking.outbox_event (
    id             UUID         NOT NULL DEFAULT gen_random_uuid(),
    aggregate_type VARCHAR(100) NOT NULL,
    aggregate_id   UUID         NOT NULL,
    event_type     VARCHAR(100) NOT NULL,
    payload        JSONB        NOT NULL,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT pk_outbox_event PRIMARY KEY (id)
);

-- The relay query of csp-worker: oldest pending rows first.
CREATE INDEX idx_outbox_event_created_at_id ON booking.outbox_event (created_at, id);

GRANT SELECT, INSERT, UPDATE, DELETE ON booking.outbox_event TO booking_writer;
GRANT SELECT ON booking.outbox_event TO booking_reader;
-- Narrower on purpose: csp-worker reads the outbox and nothing else (ADR-014).
GRANT SELECT ON booking.outbox_event TO booking_outbox_reader;
