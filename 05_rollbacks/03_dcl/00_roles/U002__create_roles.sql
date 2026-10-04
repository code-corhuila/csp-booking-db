-- Reverts V002. U003 has already removed every privilege and membership of these roles.
DROP ROLE IF EXISTS booking_outbox_reader;
DROP ROLE IF EXISTS booking_writer;
DROP ROLE IF EXISTS booking_reader;
