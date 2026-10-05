-- Reverts V008. Applied before U004: the hold cannot be dropped while its key points at it.
REVOKE SELECT, INSERT, UPDATE, DELETE ON booking.idempotency_key FROM booking_writer;
REVOKE SELECT ON booking.idempotency_key FROM booking_reader;
DROP TABLE IF EXISTS booking.idempotency_key;
