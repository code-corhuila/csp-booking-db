-- Reverts V001. The rebuild check removes booking.flyway_schema_history first, because it lives in this schema.
-- DROP SCHEMA ... CASCADE would silently destroy every later object, so this script refuses to run
-- unless every later U script has already run, in reverse order: nothing but the control table may be
-- left in the schema, and the roles of V002 must be gone.
DO $$
BEGIN
    IF EXISTS (SELECT 1
               FROM pg_class c
               JOIN pg_namespace n ON n.oid = c.relnamespace
               WHERE n.nspname = 'booking'
                 AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
                 AND c.relname <> 'flyway_schema_history') THEN
        RAISE EXCEPTION 'U001 refused: the schema booking still holds objects of later migrations. Run every later U script first, from the highest version down.';
    END IF;
    IF EXISTS (SELECT 1 FROM pg_roles
               WHERE rolname IN ('booking_reader', 'booking_writer', 'booking_outbox_reader')) THEN
        RAISE EXCEPTION 'U001 refused: the roles of V002 still exist. Run U003 and U002 first, from the highest version down.';
    END IF;
END
$$;

DROP SCHEMA IF EXISTS booking CASCADE;
