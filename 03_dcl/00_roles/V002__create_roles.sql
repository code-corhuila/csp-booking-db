-- Roles of the booking domain (ADR-013 and ADR-014). They carry permissions only: NOLOGIN and no password.
-- The login users (booking_app, worker_app) are created by csp-infra-postgres from secrets.
-- Roles belong to the whole instance, so every name starts with the domain (Annex J).
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'booking_reader') THEN
    CREATE ROLE booking_reader NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'booking_writer') THEN
    CREATE ROLE booking_writer NOLOGIN;
  END IF;
  -- Read-only access of csp-worker to booking.outbox_events (ADR-014). Narrower than booking_reader on purpose.
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'booking_outbox_reader') THEN
    CREATE ROLE booking_outbox_reader NOLOGIN;
  END IF;
END
$$;
