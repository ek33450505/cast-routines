# Changelog

## [v0.1.1] — 2026-06-05

### Fixed

- **Security/correctness backport** (`scripts/cast-db-routines.py`): ported three guards from the flagship cast-db-routines.py:
  - `_validate_output_path()` — rejects `output_dir` / `last_run_output_path` values that resolve outside `~/.claude/routines-output/`, preventing path-traversal writes to arbitrary filesystem locations.
  - `_maybe_log_failure()` + `cast_db.log_hook_failure` shim — guards can now log rejection events to `cast.db hook_failures` table (with graceful fallback if cast_db is unavailable).
  - `PROMPT_SIZE_WARN_BYTES` guard in `upsert` — logs a warning when `prompt_template` exceeds 50 000 bytes, alerting operators before context-window overflow at dispatch time.
- **Docs**: removed false "Constellation 3D graph" claim from CAST ecosystem table in README.md.
- **Docs**: updated README quick-start example to use placeholder repo slug and v7.4 version string (was hardcoded personal repo + v7.0).
- **Docs**: updated SECURITY.md version-reporting instruction to use generic command (was hardcoded personal machine path).
- **Docs**: updated release-celebration.yaml usage example to use placeholder repo/tag (was hardcoded personal repo slug).

## [0.1.0] — 2026-05-12

Initial release. Extracted from [claude-agent-team](https://github.com/ek33450505/claude-agent-team) v7.0.

### Added
- `bin/cast-routines` CLI with subcommands: list, status, get, install, uninstall, enable, disable, trigger, validate
- `scripts/cast-routine-runner.sh` — runner script (cron + manual entry point)
- `scripts/cast-db-routines.py` — SQLite logging + upsert layer for routines table
- 11 starter routine YAML templates in `routines/` covering daily briefing, inbox triage, meeting prep, PR narration, release celebration, standup, task triage, weekly cost report
- `install.sh` / `uninstall.sh` — idempotent install with PATH hint for `~/.local/bin`
- BATS test suite
- CI workflow (shellcheck + bash syntax + BATS) on macOS + Ubuntu

### Notes
- PyYAML is a hard runtime dependency for `install` and `validate` (used for YAML parsing). Install via `pip3 install pyyaml`.
- The `agent:` field in routine YAML references a Claude Code agent by name. Set `CAST_AGENTS_DIR` if you want `validate` to check the agent exists on disk before install.
- Standalone tap: works without full CAST install. Pair with [cast-agents](https://github.com/ek33450505/cast-agents) for the canonical agent set.
