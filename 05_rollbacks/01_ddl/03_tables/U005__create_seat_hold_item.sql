-- Reverts V005. Applied before U004: the hold cannot be dropped while its items exist.
REVOKE SELECT, INSERT, UPDATE, DELETE ON booking.seat_hold_item FROM booking_writer;
REVOKE SELECT ON booking.seat_hold_item FROM booking_reader;
DROP TABLE IF EXISTS booking.seat_hold_item;
