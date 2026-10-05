-- The lifecycle aggregate behind GET /reservations: one row per hold, written in the same
-- transaction as the hold. The snapshots live in seat_hold; money is integer cents
-- (Rule 2026-B).
CREATE TABLE booking.reservation (
    id           UUID         NOT NULL DEFAULT gen_random_uuid(),
    hold_id      UUID         NOT NULL,
    user_id      UUID         NOT NULL,
    showtime_id  UUID         NOT NULL,
    status       VARCHAR(50)  NOT NULL,
    total_amount BIGINT       NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    confirmed_at TIMESTAMPTZ  NULL,
    CONSTRAINT pk_reservation PRIMARY KEY (id),
    CONSTRAINT chk_reservation_status CHECK (status IN ('HELD', 'CONFIRMED', 'EXPIRED')),
    CONSTRAINT chk_reservation_total_amount CHECK (total_amount >= 0),
    -- One reservation originates from one hold; the unique index is also the FK index.
    CONSTRAINT uk_reservation_hold UNIQUE (hold_id),
    CONSTRAINT fk_reservation_hold FOREIGN KEY (hold_id)
        REFERENCES booking.seat_hold (id)
);

-- The paginated list of the caller's reservations, newest first (GET /reservations).
CREATE INDEX idx_reservation_user_created_at ON booking.reservation (user_id, created_at DESC);

GRANT SELECT, INSERT, UPDATE, DELETE ON booking.reservation TO booking_writer;
GRANT SELECT ON booking.reservation TO booking_reader;
