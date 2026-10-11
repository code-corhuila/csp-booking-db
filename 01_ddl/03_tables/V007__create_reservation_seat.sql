-- The seat labels of a reservation, one row per seat.
CREATE TABLE booking.reservation_seat (
    id             UUID        NOT NULL DEFAULT gen_random_uuid(),
    reservation_id UUID        NOT NULL,
    seat_number    VARCHAR(10) NOT NULL,
    CONSTRAINT pk_reservation_seat PRIMARY KEY (id),
    CONSTRAINT uk_reservation_seat_seat UNIQUE (reservation_id, seat_number),
    -- Its leading column is reservation_id, so it is also the FK index (Annex A).
    CONSTRAINT fk_reservation_seat_reservation FOREIGN KEY (reservation_id)
        REFERENCES booking.reservation (id) ON DELETE CASCADE
);

GRANT SELECT, INSERT, UPDATE, DELETE ON booking.reservation_seat TO booking_writer;
GRANT SELECT ON booking.reservation_seat TO booking_reader;
