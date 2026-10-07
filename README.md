# csp-booking-db

> booking bounded context: database (schema, seeds, migrations)

Part of the **Cinesync Platform** distributed system — team `cinesync-platform`, Group 1.
Governance and documentation live in [`csp-docs`](https://github.com/code-corhuila/csp-docs).

## Purpose

This repository is the **only owner of the `booking` schema** of the Cinesync Platform: its structure, seed data,
roles and migrations. `csp-booking-api` consumes the schema and never versions it. A migration of booking
that lives anywhere else is a serious fault (Norma 5.2.1).

The repository currently holds the **base scaffold only**: the layout, the schema, the roles and the rebuild
verification. The functional tables of booking are added later, each with its own migration and reversion.

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
`db-ci.yml` runs it out of order once and checks that it is refused. A `U` script added with a new migration keeps
this order: it reverts only its own `V`, and it is applied before the ones below it.

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

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `csp-docs`.

## Pull Requests and commits

- Commits follow Conventional Commits: `<type>(<scope>): <description>`, in English, lowercase and imperative.
- A Pull Request has at most **400 changed lines** (additions plus deletions) and one logical goal.
- Every Pull Request targets the permanent branch that matches its prefix, according to the diagram above.
