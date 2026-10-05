-- Reverts V004. Applied with psql from the highest version down (README, Reversion):
-- the children (V005, V006, V008) are dropped before this one.
REVOKE SELECT, INSERT, UPDATE, DELETE ON booking.seat_hold FROM booking_writer;
REVOKE SELECT ON booking.seat_hold FROM booking_reader;
DROP TABLE IF EXISTS booking.seat_hold;
