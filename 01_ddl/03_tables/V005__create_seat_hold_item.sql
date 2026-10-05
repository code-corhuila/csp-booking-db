-- One row per held seat. `showtime_id` is a copy of the hold's showtime, so the database
-- itself refuses a second active hold of the same seat (the no-double-booking rule).
CREATE TABLE booking.seat_hold_item (
    id          UUID         NOT NULL DEFAULT gen_random_uuid(),
    hold_id     UUID         NOT NULL,
    showtime_id UUID         NOT NULL,
    seat_number VARCHAR(10)  NOT NULL,
    status      VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_seat_hold_item PRIMARY KEY (id),
    CONSTRAINT chk_seat_hold_item_status CHECK (status IN ('HELD', 'RELEASED', 'CONFIRMED')),
    -- A seat appears at most once in one hold. Its leading column is hold_id, so it is
    -- also the index of the foreign key (Annex A: every foreign key column is indexed).
    CONSTRAINT uk_seat_hold_item_seat UNIQUE (hold_id, seat_number),
    CONSTRAINT fk_seat_hold_item_hold FOREIGN KEY (hold_id)
        REFERENCES booking.seat_hold (id) ON DELETE CASCADE
);

-- The invariant of the story: one active row per seat and showtime. The partial unique
-- index lets the transaction that violates it fail instead of holding a seat twice.
CREATE UNIQUE INDEX uk_seat_hold_item_active_seat
    ON booking.seat_hold_item (showtime_id, seat_number)
    WHERE status IN ('HELD', 'CONFIRMED');

GRANT SELECT, INSERT, UPDATE, DELETE ON booking.seat_hold_item TO booking_writer;
GRANT SELECT ON booking.seat_hold_item TO booking_reader;
