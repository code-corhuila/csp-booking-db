-- Schema-level grants. Table-level grants are added by the migration that creates each table.
-- csp-booking-api writes only through booking_writer, which also reads (it inherits booking_reader).
GRANT USAGE ON SCHEMA booking TO booking_reader, booking_writer, booking_outbox_reader;
GRANT booking_reader TO booking_writer;

-- The login users already exist: csp-infra-postgres creates them before the migrations run (Annex J.5.5).
GRANT booking_writer TO booking_app;
-- csp-worker may only read the outbox (ADR-014). It receives no privilege on any other booking table.
GRANT booking_outbox_reader TO worker_app;
