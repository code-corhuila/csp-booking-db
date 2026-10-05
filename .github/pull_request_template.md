## What changes and why
<!-- One paragraph. The reviewer reads this before the diff. -->


## User story (required)
<!-- Replace NN with the story issue of csp-docs. A base scaffold pull request (structure only) writes:
     "Not applicable: base scaffold, structure only". -->
Refs: code-corhuila/csp-docs#NN


## How it was tested
- Rebuild check (migrate, migrate again, `U` scripts, migrate):
- `db-ci.yml` result:


## Size
<!-- Run: git diff --numstat origin/develop...HEAD -->
Added: · Deleted: · Total:  (limit 400, excluding tests and generated files)


## Promotion trail (only for pull requests into `qa` or `main`)
<!-- List the original commits this pull request re-applies.
     Every commit must carry the line "(cherry picked from commit <sha>)". -->
-


## Checklist
- [ ] Meets the acceptance criteria of the user story (or is a base scaffold, not applicable)
- [ ] Local validation passes (migrations apply from an empty database)
- [ ] Under 400 changed lines, excluding tests and generated files
- [ ] Title follows Conventional Commits
- [ ] Only NEW migrations: no applied migration was edited
- [ ] Every `V` migration has its `U` script in `05_rollbacks/`
- [ ] No credentials: roles are `NOLOGIN` and carry no password
- [ ] Schema follows the data model of `csp-docs` and touches only the `booking` schema
- [ ] No foreign key and no transaction crosses into another domain (Annex J)
- [ ] Into `qa` or `main`: every commit was re-applied with `git cherry-pick -x`
