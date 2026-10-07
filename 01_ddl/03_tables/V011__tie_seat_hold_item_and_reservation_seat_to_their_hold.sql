-- Two gaps of the no-double-booking guarantee, both inside the schema booking (no cross-schema FK).
--
-- 1. seat_hold_item.showtime_id is a copy of the showtime of its hold, and
--    uk_seat_hold_item_active_seat protects (showtime_id, seat_number). A copy that disagrees with the
--    hold would make that index protect a key that does not exist. The composite foreign key makes the
--    copy impossible to get wrong. (hold_id, showtime_id) is not unique in the items table: a hold
--    has one item per seat, so the referencing side only gets a plain index (Annex A).
ALTER TABLE booking.seat_hold
    ADD CONSTRAINT uk_seat_hold_id_showtime UNIQUE (id, showtime_id);

CREATE INDEX idx_seat_hold_item_hold_showtime ON booking.seat_hold_item (hold_id, showtime_id);

ALTER TABLE booking.seat_hold_item
    ADD CONSTRAINT fk_seat_hold_item_hold_showtime FOREIGN KEY (hold_id, showtime_id)
        REFERENCES booking.seat_hold (id, showtime_id) ON DELETE CASCADE;

-- 2. reservation_seat only knew its reservation, so nothing stopped a reservation from listing a seat
--    that its hold never held. It now carries the hold of its reservation, and two composite foreign
--    keys tie the row to that hold and to one of the items of that hold. A reservation is created with
--    reservation.id = hold_id (uk_reservation_hold), so the column is written with the same value.
ALTER TABLE booking.reservation
    ADD CONSTRAINT uk_reservation_id_hold UNIQUE (id, hold_id);

ALTER TABLE booking.reservation_seat ADD COLUMN hold_id UUID;

UPDATE booking.reservation_seat rs
SET hold_id = r.hold_id
FROM booking.reservation r
WHERE r.id = rs.reservation_id;

ALTER TABLE booking.reservation_seat ALTER COLUMN hold_id SET NOT NULL;

-- The referencing columns of the second key; the first key leads with reservation_id, which
-- uk_reservation_seat_seat already indexes.
CREATE INDEX idx_reservation_seat_hold_seat ON booking.reservation_seat (hold_id, seat_number);

ALTER TABLE booking.reservation_seat
    ADD CONSTRAINT fk_reservation_seat_reservation_hold FOREIGN KEY (reservation_id, hold_id)
        REFERENCES booking.reservation (id, hold_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_reservation_seat_hold_item FOREIGN KEY (hold_id, seat_number)
        REFERENCES booking.seat_hold_item (hold_id, seat_number);
