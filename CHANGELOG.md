# Changelog

All notable changes of `csp-booking-db` are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the versions follow
[Semantic Versioning](https://semver.org/). A release is a `release/<version>` branch cut from `main` and filled with the commits of `qa`,
re-applied with `git cherry-pick -x` (numerals 6.2.3, 10 and 11 of the course norm); it reaches `main` by pull request, never by merging `qa`,
and is tagged `v<version>` once it is merged.

## [Unreleased]

## [2.0.0] - 2026-10-08

MVP 2 (Cut 2). The `booking` schema of the stories HU-BOOKING-001, HU-BOOKING-002 and HU-BOOKING-003 of
[csp-booking-api](https://github.com/code-corhuila/csp-booking-api).

### Added

- Tables of the booking domain: hold, seats of the hold, reservation, idempotency key and transactional outbox.
  ([#15](https://github.com/code-corhuila/csp-booking-db/pull/15))
- Cross-domain check in the pull request template. ([#22](https://github.com/code-corhuila/csp-booking-db/pull/22))
- README with the tables of Cut 2 and what is missing. ([#33](https://github.com/code-corhuila/csp-booking-db/pull/33))

### Changed

- `V010` revokes the unused `DELETE` grant on the outbox: nothing deletes from it and the absence of a purge is documented.
  ([#28](https://github.com/code-corhuila/csp-booking-db/pull/28))
- `V011` ties `seat_hold_item` and `reservation_seat` to their hold with composite foreign keys, backfilling `hold_id` before it
  becomes `NOT NULL`. `csp-booking-api` writes that column since its release 2.0.0, so deploy this schema first.
  ([#30](https://github.com/code-corhuila/csp-booking-db/pull/30))

### Fixed

- The migration executor connects with the domain user. ([#12](https://github.com/code-corhuila/csp-booking-db/pull/12))
- `U001` refuses to drop the schema when later objects remain or when the roles of `V002` are missing, so a partial or
  out-of-order rollback fails instead of destroying data. ([#27](https://github.com/code-corhuila/csp-booking-db/pull/27))

### Known limits

- No seed data: `02_dml/` and `04_tcl/` hold only their folders, the tables start empty.
- The executor runs as the administrator of the instance, not as an owner of the schema
  ([#26](https://github.com/code-corhuila/csp-booking-db/issues/26)).
- The schema is not published as a versioned artifact that `csp-booking-api` could pin by tag instead of by commit
  ([#25](https://github.com/code-corhuila/csp-booking-db/issues/25)).
- No outbox purge or retention ([#18](https://github.com/code-corhuila/csp-booking-db/issues/18)).

## [0.1.0] - 2026-10-05

### Added

- Governance files, the migration families, the `booking` schema and roles, the migration executor, the CI rebuild workflow and
  the pull request template.
