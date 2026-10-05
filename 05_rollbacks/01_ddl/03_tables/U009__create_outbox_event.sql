-- Reverts V009. The outbox has no foreign key, so it is reverted first in any order.
REVOKE SELECT, INSERT, UPDATE, DELETE ON booking.outbox_event FROM booking_writer;
REVOKE SELECT ON booking.outbox_event FROM booking_reader;
REVOKE SELECT ON booking.outbox_event FROM booking_outbox_reader;
DROP TABLE IF EXISTS booking.outbox_event;
