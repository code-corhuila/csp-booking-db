-- Reverts V006. Applied before U004: the hold cannot be dropped while its reservation exists.
REVOKE SELECT, INSERT, UPDATE, DELETE ON booking.reservation FROM booking_writer;
REVOKE SELECT ON booking.reservation FROM booking_reader;
DROP TABLE IF EXISTS booking.reservation;
