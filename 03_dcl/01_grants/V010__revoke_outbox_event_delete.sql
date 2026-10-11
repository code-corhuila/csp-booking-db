-- booking.outbox_event is never purged by this domain. V009 granted DELETE to booking_writer with no
-- process behind it, and the table has no processed_at: the publication state lives in schema worker
-- (ADR-014), so an age-based delete cannot know whether a row was relayed and could drop an event
-- while csp-worker is down. The permission is removed so that it matches reality. A retention policy
-- is a future change that decides who deletes and how it consults the cursor of the worker.
REVOKE DELETE ON booking.outbox_event FROM booking_writer;
