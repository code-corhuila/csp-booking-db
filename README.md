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
