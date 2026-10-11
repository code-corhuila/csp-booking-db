-- Reverts V011. Applied before U010: it only removes what V011 added, children before parents.
ALTER TABLE booking.reservation_seat
    DROP CONSTRAINT IF EXISTS fk_reservation_seat_hold_item,
    DROP CONSTRAINT IF EXISTS fk_reservation_seat_reservation_hold;
DROP INDEX IF EXISTS booking.idx_reservation_seat_hold_seat;
ALTER TABLE booking.reservation_seat DROP COLUMN IF EXISTS hold_id;
ALTER TABLE booking.reservation DROP CONSTRAINT IF EXISTS uk_reservation_id_hold;

ALTER TABLE booking.seat_hold_item DROP CONSTRAINT IF EXISTS fk_seat_hold_item_hold_showtime;
DROP INDEX IF EXISTS booking.idx_seat_hold_item_hold_showtime;
ALTER TABLE booking.seat_hold DROP CONSTRAINT IF EXISTS uk_seat_hold_id_showtime;
