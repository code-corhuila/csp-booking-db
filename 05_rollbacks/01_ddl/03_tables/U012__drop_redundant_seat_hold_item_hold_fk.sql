-- Reverts V012: puts back the single-column key exactly as V005 created it.
ALTER TABLE booking.seat_hold_item
    ADD CONSTRAINT fk_seat_hold_item_hold FOREIGN KEY (hold_id)
        REFERENCES booking.seat_hold (id) ON DELETE CASCADE;
