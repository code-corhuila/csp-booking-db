-- Reverts V003. Applied before U002 (roles) and U001 (schema), from the highest version down.
REVOKE booking_outbox_reader FROM worker_app;
REVOKE booking_writer FROM booking_app;
REVOKE booking_reader FROM booking_writer;
REVOKE USAGE ON SCHEMA booking FROM booking_reader, booking_writer, booking_outbox_reader;
