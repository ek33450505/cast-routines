# Contributing to cast-routines

Thanks for your interest! cast-routines is a small, focused tap with a stable surface. Contributions that add new starter templates, harden validation, or improve cross-platform support are especially welcome.

## Prerequisites

- **bash** + **python3** — both ship with macOS / standard Linux
- **PyYAML** — `pip3 install pyyaml`
- **sqlite3** — usually present
- **BATS** — for tests. `brew install bats-core` (macOS) or `apt-get install bats` (Ubuntu)
- **Claude Code CLI** — `claude` on PATH

## Quick Start

```bash
git clone https://github.com/ek33450505/cast-routines
cd cast-routines
bash install.sh
cast-routines list
```

`install.sh` is idempotent — safe to re-run after pulling changes.

## How to Modify

**CLI** (`bin/cast-routines`): The dispatch shim. Adds/edits subcommands here. Keep the script self-contained — no external sourcing.

**Runner** (`scripts/cast-routine-runner.sh`): The entry point invoked by cron. Handles env var setup, MCP pre-flight, prompt argument substitution, and agent dispatch. Test changes with `--dry-run` first.

**DB layer** (`scripts/cast-db-routines.py`): SQLite upsert, list, status. Schema lives in the `routines` table — changes here must include an idempotent `CREATE TABLE IF NOT EXISTS` or `ALTER TABLE ... ADD COLUMN` shim.

**Routine templates** (`routines/*.yaml`): Starter content shipped to users on install. Each must:
- Have all required fields (`name`, `agent`, `prompt_template`, `output_dir`, `trigger.type`)
- Pass `cast-routines validate`
- Use only standard CAST agents (or document the prerequisite clearly in `notes:`)

## Adding a new starter template

1. Create `routines/<your-routine-name>.yaml`
2. Set `enabled: false` by default for new templates (so users opt in rather than auto-fire on install)
3. Document any MCP servers required in `mcp_required:` and the `notes:` block
4. Run `bash bin/cast-routines validate routines/<your-routine-name>.yaml`
5. Add a row to the "Starter templates" table in `README.md`

## PR Checklist

- [ ] `bash install.sh` runs cleanly on a fresh `~/.claude/`
- [ ] `bash -n bin/cast-routines && bash -n scripts/cast-routine-runner.sh && bash -n install.sh && bash -n uninstall.sh` — all syntax-check pass
- [ ] BATS tests pass: `bats tests/`
- [ ] `bash install.sh && bash uninstall.sh` round-trip — both succeed, no orphan files
- [ ] No hardcoded `/Users/<name>/` paths — use `$HOME` or `~/`
- [ ] `CHANGELOG.md` updated for any user-visible change
- [ ] `cast-routines validate` passes on every new or modified YAML

## Code style

- All scripts: `set -euo pipefail`
- Quote variable expansions: `"$var"`
- Use `[[ ]]` for conditionals, not `[ ]`
- ShellCheck clean — no warnings on bash files
- Python: stdlib only except for PyYAML

## Reporting issues

Use the GitHub issue templates under `.github/ISSUE_TEMPLATE/` for bug reports, feature requests, or new-template proposals.
