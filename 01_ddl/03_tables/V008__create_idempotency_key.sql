-- Idempotency of POST /holds (Norma 5.3.8). The hold and the key are written in one
-- transaction with ON CONFLICT DO NOTHING: a replay of the same key returns the original
-- hold with 200 and creates nothing, and the same key with another payload answers 409.
CREATE TABLE booking.idempotency_key (
    key          TEXT        NOT NULL,
    hold_id      UUID        NOT NULL,
    request_hash TEXT        NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT pk_idempotency_key PRIMARY KEY (key),
    CONSTRAINT chk_idempotency_key_length CHECK (char_length(key) BETWEEN 8 AND 128),
    -- One key per hold: the unique index is also the index of the foreign key.
    CONSTRAINT uk_idempotency_key_hold UNIQUE (hold_id),
    CONSTRAINT fk_idempotency_key_hold FOREIGN KEY (hold_id)
        REFERENCES booking.seat_hold (id) ON DELETE CASCADE
);

-- The purge of keys older than 24 hours (internal maintenance, ADR-014).
CREATE INDEX idx_idempotency_key_created_at ON booking.idempotency_key (created_at);

GRANT SELECT, INSERT, UPDATE, DELETE ON booking.idempotency_key TO booking_writer;
GRANT SELECT ON booking.idempotency_key TO booking_reader;
