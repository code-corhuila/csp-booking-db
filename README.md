# csp-booking-db

> booking bounded context: database (schema, seeds, migrations)

Part of the **Cinesync Platform** distributed system — team `cinesync-platform`, Group 1.
Governance and documentation live in [`csp-docs`](https://github.com/code-corhuila/csp-docs).

## Purpose

This repository is the **only owner of the `booking` schema** of the Cinesync Platform: its structure, seed data,
roles and migrations. `csp-booking-api` consumes the schema and never versions it. A migration of booking
that lives anywhere else is a serious fault (Norma 5.2.1).

The repository holds the schema, the roles and the grants, and the tables of the three stories of Cut 2 (HU-BOOKING-001,
002 and 003), each migration with its reversion, plus the rebuild verification that runs on every pull request.

## Schema

Migrations `V001` to `V012`; every `V<n>` has its `U<n>` in `05_rollbacks/`.

| Migration | What it creates |
|---|---|
| `V001` | The schema `booking` |
| `V002` | The roles `booking_reader`, `booking_writer` and `booking_outbox_reader` (all `NOLOGIN`) |
| `V003` | The grants: `booking_writer` to the login user `booking_app`, `booking_outbox_reader` to `worker_app` |
| `V004`, `V005` | `seat_hold` (the temporary hold and its snapshots) and `seat_hold_item` (one row per held seat) |
| `V006`, `V007` | `reservation` (the lifecycle: `HELD`, `CONFIRMED`, `EXPIRED`) and `reservation_seat` |
| `V008` | `idempotency_key` (one key per hold) |
| `V009` | `outbox_event` (the transactional outbox, with no `processed_at`: the worker keeps the state in its own schema) |
| `V010` | Revokes `DELETE` on `outbox_event` from `booking_writer` (see Outbox retention) |
| `V011` | The composite keys that tie a seat to its hold: `seat_hold_item` to the showtime of its hold, and `reservation_seat` to its hold and to a held seat |
| `V012` | Drops `fk_seat_hold_item_hold` of `V005`: the composite key of `V011` already implies it |

The rule that no seat is held twice is the partial unique index `uk_seat_hold_item_active_seat` over
`(showtime_id, seat_number)` where the status is `HELD` or `CONFIRMED`: a seat becomes available again only when its row
leaves that set (`RELEASED`). The login users are not created here: `csp-infra-postgres` creates them from secrets, and
the schema assumes them.

## Where the data is

The schema `booking` lives in the database `csp` (`PG_DATABASE`) of the single PostgreSQL instance of
`csp-infra-postgres`. The executor of this repository connects with `BOOKING_DB_USER` and `BOOKING_DB_PASSWORD`, which in
the platform are the administrator of the instance, because the first migrations create the schema and the roles
(`csp-booking-db#26` tracks giving it a narrower owner). The service reads and writes as `booking_app` and the worker
reads the outbox as `worker_app`.

## Stack

| Item | Decision | Record |
|---|---|---|
| Engine | PostgreSQL, schema `booking` | [ADR-013](https://github.com/code-corhuila/csp-docs/blob/main/05-architecture/decisions/records/ADR-013-booking-postgresql-flyway.md) |
| Migration tool | Flyway, with `U` reversion scripts | [ADR-013](https://github.com/code-corhuila/csp-docs/blob/main/05-architecture/decisions/records/ADR-013-booking-postgresql-flyway.md) |
| Outbox reader of the worker | Read-only role `booking_outbox_reader` | [ADR-014](https://github.com/code-corhuila/csp-docs/blob/main/05-architecture/decisions/records/ADR-014-booking-outbox-relay-read-only.md) |
| Policy | Migrations live only in each `-db` | [`migration-strategy.md`](https://github.com/code-corhuila/csp-docs/blob/main/06-data/migration-strategy.md) |

The single PostgreSQL instance and its volume are defined in `csp-infra-postgres` (Annex J). This repository defines
**no database service and no volume**: it provides only the migration executor.

## Related repositories

| Repository | Relation |
|---|---|
| `csp-booking-api` | Connects with the user `booking_app`; runs no migration |
| `csp-infra-postgres` | Defines the instance, creates the login users from secrets and composes the executor |
| `csp-worker` | Reads the booking outbox through the role `booking_outbox_reader` and never writes the schema |
| `csp-docs` | Governance, data model, contracts and ADRs |

## Layout

```
flyway.toml                  locations (the four families), naming validation, schema booking, clean disabled
01_ddl/ 02_dml/ 03_dcl/ 04_tcl/   migrations V<version>__<description>.sql, by family and sub-folder
05_rollbacks/                U<version>__<description>.sql: the reversion of every V<version>
deploy/compose.yml           the migration executor (no database service)
.github/workflows/db-ci.yml  rebuilds the schema from an empty database on every pull request
```

The order of the migrations is the version in the file name (`V001`, `V002`, ...): one sequence for the whole
repository, whatever the folder. A new migration takes the next number, and a migration that is already applied is
never edited (Flyway refuses it with a checksum error). The history lives in `booking.flyway_schema_history`.

## Run the executor

The instance belongs to `csp-infra-postgres`, which also composes this file. To run the executor alone, start that instance on the `platform` network and, from this repository:

```bash
cp .env.example .env     # and set the real values; never commit .env
docker compose -f deploy/compose.yml --env-file .env --profile tooling run --rm booking-db-migrate            # migrate
docker compose -f deploy/compose.yml --env-file .env --profile tooling run --rm booking-db-migrate validate   # checksums
```

## Reversion

Flyway Community does not undo, and `flyway undo` is not used here. The reversion of `V<n>` is the script
`U<n>` in `05_rollbacks/`, applied with `psql` **from the highest version down**. Before `U001`, the control table
`booking.flyway_schema_history` is dropped, because `U001` drops the schema. `db-ci.yml` runs exactly this order:
migrate, migrate again (nothing to apply), every `U` script descending, migrate. In production a correction is a new
forward migration.

**Never run `U001` unless every later `U` has already run, in reverse order.** `U001` enforces it: it fails, and
drops nothing, while the schema holds any object other than the control table or while the roles of `V002` exist.
`db-ci.yml` runs it out of order twice (tables still present, then only the roles left) and checks that it is refused. A `U` script added with a new migration keeps
this order: it reverts only its own `V`, and it is applied before the ones below it.

## Outbox retention

`booking.outbox_event` has no purge. The API only inserts into it and `csp-worker` only reads it (`booking_outbox_reader`), and
the publication state lives in the schema `worker` (ADR-014), so a delete by age could remove an event that was never relayed
while the worker is down. For that reason `booking_writer` has no `DELETE` on the table (`V010`). The table grows until a
retention change decides who deletes and consults the cursor of the worker first.

## Versions

The schema is published as a **version of this repository**: a semantic tag `vX.Y.Z` on `main` (numeral 11.5), with the
GitHub Release of the same name whose notes are the section of `CHANGELOG.md`. There is no migration image and no separate
bundle (Annex J keeps only the executor in `deploy/`). The first one is `v2.0.0`, with `V001` to `V012`.

**Cut a version** (the promotion to `main` is a decision of the team lead):

1. Branch `release/X.Y.Z` from `origin/main`. Re-apply with `git cherry-pick -m 1 -x` the merges of `qa` that `main` does
   not have yet (compare the `(cherry picked from commit ...)` trailers), and add the section `[X.Y.Z]` of `CHANGELOG.md`.
   Check that `git diff origin/qa HEAD` is empty.
2. Pull request to `main`; it needs the approval of `ariel5253`. A correction after the approval is one more commit on the
   same branch (never a force push) and asks for a new review.
3. After the merge, tag the head of `main` and publish the release:

```bash
git tag -a vX.Y.Z <sha of the head of main> -m "csp-booking-db X.Y.Z"
git push origin vX.Y.Z
gh release create vX.Y.Z --verify-tag --title vX.Y.Z --notes-file <the section [X.Y.Z] of CHANGELOG.md>
```

A tag is never moved: a correction is a new version. A migration that was applied is never edited, so a version only adds
`V<n>` files.

**Consume a version.** A consumer pins the tag, not `develop` and not a commit, so a green run says which published schema
it tested and a change here cannot break an unrelated pull request. `csp-booking-api` does it in its CI: the checkout of
this repository uses `ref: v2.0.0` with a read-only deploy key and applies every `V*.sql` file in version order. To move to a
new version, change that `ref` in a pull request of its own. To try a migration that is not tagged yet, point `ref` at its
commit in the branch of that pull request and put the tag back before merging.

## What is missing

- **No seed data.** `02_dml/` and `04_tcl/` hold only their folders: the tables start empty.
- **The executor runs as the administrator** of the instance, not as an owner of the schema (`csp-booking-db#26`).
- **No outbox purge or retention, by decision of Cut 2** (`csp-booking-db#18`, closed with that decision), see above: it is
  reopened when the cursor of the worker can be consulted before deleting.

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.
A branch named `qa/...` cannot be created while the branch `qa` exists (Git refuses the reference), so the promotion
branches of this repository are named `qa-promote/<repo>-<description>` (ADR-021).

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `csp-docs`.

## Pull Requests and commits

- Commits follow Conventional Commits: `<type>(<scope>): <description>`, in English, lowercase and imperative.
- A Pull Request has at most **400 changed lines** (additions plus deletions) and one logical goal.
- Every Pull Request targets the permanent branch that matches its prefix, according to the diagram above.
