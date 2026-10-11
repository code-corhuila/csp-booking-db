-- V011 added fk_seat_hold_item_hold_showtime FOREIGN KEY (hold_id, showtime_id) REFERENCES seat_hold (id, showtime_id).
-- seat_hold.id is the primary key, so every row that satisfies the composite key already satisfies the
-- single-column key of V005 (fk_seat_hold_item_hold, same ON DELETE CASCADE): the older constraint
-- guarantees nothing the new one does not, and it only adds one more check to each insert or update of
-- seat_hold_item. Annex A keeps the foreign key columns indexed: hold_id stays indexed by
-- uk_seat_hold_item_seat (hold_id, seat_number) and by idx_seat_hold_item_hold_showtime.
ALTER TABLE booking.seat_hold_item DROP CONSTRAINT fk_seat_hold_item_hold;
