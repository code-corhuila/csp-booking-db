-- Reverts V007. Applied before U006: the reservation cannot be dropped while its seats exist.
REVOKE SELECT, INSERT, UPDATE, DELETE ON booking.reservation_seat FROM booking_writer;
REVOKE SELECT ON booking.reservation_seat FROM booking_reader;
DROP TABLE IF EXISTS booking.reservation_seat;
