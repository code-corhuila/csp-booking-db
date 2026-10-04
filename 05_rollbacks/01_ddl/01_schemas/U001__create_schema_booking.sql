-- Reverts V001. The rebuild check removes booking.flyway_schema_history first, because it lives in this schema.
DROP SCHEMA IF EXISTS booking CASCADE;
