-- A temporary hold of seats for a showtime: the seat lock of the booking domain.
-- The title and the room are copied here once at creation and never refreshed, so a
-- ticket stays displayable if Catalog changes later (ADR-020, data-dictionary 06-data).
-- gen_random_uuid() is provided by PostgreSQL 16 itself: the schema needs no extension.
CREATE TABLE booking.seat_hold (
    id                   UUID         NOT NULL DEFAULT gen_random_uuid(),
    user_id              UUID         NOT NULL,
    showtime_id          UUID         NOT NULL,
    status               VARCHAR(50)  NOT NULL,
    movie_title_snapshot VARCHAR(255) NOT NULL,
    room_name_snapshot   VARCHAR(255) NOT NULL,
    showtime_starts_at   TIMESTAMPTZ  NULL,
    expires_at           TIMESTAMPTZ  NOT NULL,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT pk_seat_hold PRIMARY KEY (id),
    CONSTRAINT chk_seat_hold_status CHECK (status IN ('HELD', 'EXPIRED', 'CONFIRMED'))
);

-- csp-worker selects the overdue holds through this index (Norma 4.3): active rows only.
CREATE INDEX idx_seat_hold_status_expires_at
    ON booking.seat_hold (status, expires_at)
    WHERE status = 'HELD';

GRANT SELECT, INSERT, UPDATE, DELETE ON booking.seat_hold TO booking_writer;
GRANT SELECT ON booking.seat_hold TO booking_reader;
