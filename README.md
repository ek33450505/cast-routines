# cast-routines

Schedule autonomous Claude Code routines — daily briefings, inbox triage, infrastructure health checks — via YAML configs and cron.

cast-routines is a standalone tap from the [CAST ecosystem](https://github.com/ek33450505/claude-agent-team). It generalizes the JARVIS-style "personal assistant agent" pattern into a small, declarative framework: write a YAML, register it, and your routine fires on a schedule with the agent you specified.

## Install (Homebrew)

```bash
brew tap ek33450505/cast-routines
brew install cast-routines
bash "$(brew --prefix cast-routines)/install.sh"
```

## Manual install

```bash
git clone https://github.com/ek33450505/cast-routines.git
cd cast-routines
bash install.sh
```

## Quick start

```bash
# List all installed routines
cast-routines list

# Validate a YAML before installing
cast-routines validate ~/.claude/routines/daily-briefing.yaml

# Install (registers in cast.db, adds cron entry if trigger.type=cron)
cast-routines install ~/.claude/routines/daily-briefing.yaml

# Trigger manually
cast-routines trigger daily-briefing --dry-run
cast-routines trigger release-celebration --arg repo=ek33450505/claude-agent-team --arg version=v7.0
```

## Routine YAML schema

```yaml
name: daily-briefing                 # slug — lowercase, alphanumerics + - + _
description: "Run morning-briefing agent at 8am daily."
trigger:
  type: cron                         # cron | manual
  value: "0 7 * * *"                 # required when type=cron (5-field cron expr)
agent: morning-briefing              # the CAST agent that will be dispatched
prompt_template: |
  Run the daily briefing. ...        # the prompt sent to the agent
output_dir: "~/.claude/routines-output/daily-briefing"
enabled: true                        # default: true
mcp_required: []                     # optional — list of MCP servers required
prompt_args:                         # optional — for manual triggers w/ --arg
  - name: repo
    required: true
    description: "GitHub repo slug"
notes: |
  Free-form notes for the human maintainer.
```

## Subcommands

| Command | Purpose |
|---|---|
| `cast-routines list` | List all installed routines (from cast.db) |
| `cast-routines status [name]` | Detailed status — last run, next fire, exit code |
| `cast-routines get <name>` | Get a single routine record as JSON |
| `cast-routines validate <yaml>` | Lint a YAML spec before install |
| `cast-routines install <yaml>` | Register in cast.db; install cron entry if applicable |
| `cast-routines uninstall <name>` | Remove cron entry and mark disabled (YAML preserved) |
| `cast-routines enable <name>` | Re-enable + reinstall cron |
| `cast-routines disable <name>` | Disable + remove cron |
| `cast-routines trigger <name> [--dry-run] [--arg k=v ...]` | Fire a routine manually |

## Environment

| Var | Default | Purpose |
|---|---|---|
| `CAST_DB_PATH` | `~/.claude/cast.db` | SQLite path |
| `CAST_ROUTINES_DIR` | `~/.claude/routines` | Where YAML configs live |
| `CAST_SCRIPTS_DIR` | `~/.claude/scripts` | Where helpers are installed |
| `CAST_AGENTS_DIR` | (unset) | Optional. When set, `validate` checks the named `agent:` exists at `$CAST_AGENTS_DIR/<agent>.md`. |
| `CAST_CRONTAB_CMD` | `crontab` | Override crontab binary (useful in tests) |

## Starter templates

11 ready-to-go routine templates ship in `routines/` and are copied into `~/.claude/routines/` on install:

| Template | Trigger | Purpose |
|---|---|---|
| `daily-briefing.yaml` | cron 07:00 | Morning briefing — git activity, CAST health |
| `daily-cast-health.yaml` | cron daily | CAST system health snapshot |
| `email-triage.yaml` | cron | Inbox triage via Gmail MCP |
| `knowledge-curator.yaml` | cron | Obsidian vault link curation |
| `learning-scout.yaml` | cron | Topic monitoring + research notes |
| `meeting-prep.yaml` | cron | Pre-meeting briefs from calendar |
| `pr-narrator.yaml` | manual | PR storytelling for stakeholders |
| `release-celebration.yaml` | manual | Draft LinkedIn + dev.to outline on release |
| `standup-writer.yaml` | cron weekday | Outward-facing standup draft |
| `task-triage.yaml` | cron | Todoist inbox triage |
| `weekly-cost-report.yaml` | cron weekly | API spend report |

## Prerequisites

- **bash** + **python3** — both ship with macOS / standard Linux
- **PyYAML** — `pip3 install pyyaml`
- **sqlite3** — usually installed; required for the `list` / `status` / `get` commands
- **crontab** — required only for `trigger.type=cron` routines
- **Claude Code CLI** — the framework that dispatches the agents

cast-routines does NOT require the full CAST framework, but the routines themselves reference CAST agents by name (e.g., `agent: morning-briefing`). You can either:

1. **Install full CAST** ([claude-agent-team](https://github.com/ek33450505/claude-agent-team)) for the canonical agent set
2. **Install cast-agents standalone** ([cast-agents](https://github.com/ek33450505/cast-agents)) for just the agents
3. **Author your own agents** in `~/.claude/agents/` — any agent your Claude Code can dispatch works

Set `CAST_AGENTS_DIR=~/.claude/agents/core` (or wherever your agents live) to enable `validate`'s agent-existence check.

## How routines fire

```
  cron → bash ~/.claude/scripts/cast-routine-runner.sh <name> --from-cron
              ↓
              Reads ~/.claude/routines/<name>.yaml
              ↓
              Dispatches the named agent via Claude Code Agent SDK
              ↓
              Writes output to <output_dir>/
              ↓
              Logs result to cast.db (routines table)
```

Manual triggers skip cron and execute synchronously via `cast-routines trigger`.

## The CAST Ecosystem

CAST is distributed as a constellation of independently-installable packages — pick what you need. All are MIT-licensed and Homebrew-tappable.

| Repo | One line |
|---|---|
| [claude-agent-team](https://github.com/ek33450505/claude-agent-team) | The full CAST framework — agents, hooks, routines, observability |
| [cast-agents](https://github.com/ek33450505/cast-agents) | 22 specialist agents (commit, debug, review, plan, test, research, …) |
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 hook scripts — observability, safety gates, dispatch |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent agent memory with FTS5 search + MCP server |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session cost + token-spend tracking |
| [cast-security](https://github.com/ek33450505/cast-security) | Policy gates, PII redaction, audit trail |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard (Python + Textual) |
| [cast-parallel](https://github.com/ek33450505/cast-parallel) | Plan execution split across parallel git worktrees |
| [cast-claudes_journal](https://github.com/ek33450505/cast-claudes_journal) | Cross-session continuity via Obsidian vault |
| [cast-routines](https://github.com/ek33450505/cast-routines) | Scheduled Claude Code routines via YAML + cron ← **you are here** |
| [cast-time](https://github.com/ek33450505/cast-time) | SessionStart hook injecting local time + timezone |
| [cast-doctor](https://github.com/ek33450505/cast-doctor) | Read-only health check for any Claude Code install |

## License

MIT — see [LICENSE](LICENSE).
