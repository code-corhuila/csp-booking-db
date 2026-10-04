-- Schema of the booking domain. Nothing of this domain lives in public (Annex A, rule 9).
-- Flyway already creates it because of `schemas` in flyway.toml; the statement is kept so the
-- schema is declared by a migration and the file is safe to run again.
CREATE SCHEMA IF NOT EXISTS booking;
