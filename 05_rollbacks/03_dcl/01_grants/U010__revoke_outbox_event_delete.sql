-- Reverts V010: gives back the DELETE privilege V009 granted to booking_writer.
GRANT DELETE ON booking.outbox_event TO booking_writer;
