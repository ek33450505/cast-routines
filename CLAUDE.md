# cast-routines

## Install
```bash
bash install.sh
# or: brew install ek33450505/cast-routines/cast-routines
```

## Run
```bash
cast-routines list
cast-routines install ~/.claude/routines/daily-briefing.yaml
cast-routines trigger <name> [--dry-run] [--arg k=v ...]
cast-routines validate <yaml-path>
cast-routines status [name]
cast-routines enable|disable|uninstall <name>
```

## Test
```bash
bats tests/cast-routines.bats
```

## Non-obvious

- **PyYAML required** for any subcommand that reads `.yaml` routines: `pip3 install pyyaml` before first use. Install warns but does not abort if missing.
- Routine YAMLs in `routines/` are **templates only** — they are copied to `~/.claude/routines/` on install and ignored at runtime. Edit the copies in `~/.claude/routines/`, not the repo.
- `CAST_BIN_DIR` overrides the default install target (`~/.local/bin`).
- `CAST_AGENTS_DIR` enables agent-existence checks in `validate`; omit to skip.
- `CAST_CRONTAB_CMD` swaps the crontab binary — used in tests to avoid touching real crontab.
- Routine name must match `^[a-z][a-z0-9_-]{0,63}$` — path traversal guard; non-matching names are hard-rejected.
- `uninstall` preserves the YAML in `~/.claude/routines/` — it only removes the cron entry and disables the DB record.
