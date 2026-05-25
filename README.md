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

## CAST Ecosystem

> Auto-synced from [claude-agent-team/docs/ecosystem.md](https://github.com/ek33450505/claude-agent-team/blob/main/docs/ecosystem.md). Run `~/Projects/personal/claude-agent-team/scripts/sync-ecosystem-readme.sh` to refresh.

<!-- ECOSYSTEM_START -->
| Repo | Description | Latest | Install |
|---|---|---|---|
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 auditable hook scripts — observability, safety guards, quality gates. SessionStart, PreToolUse, PostToolUse, PostCompact. | ![](https://img.shields.io/github/v/release/ek33450505/cast-hooks?style=flat-square) | `brew tap ek33450505/cast-hooks && brew install cast-hooks` |
| [cast-agents](https://github.com/ek33450505/cast-agents) | 23 specialist agents — commit, debug, review, plan, test, research, and more. Agent definitions with YAML frontmatter. v7-synced. | ![](https://img.shields.io/github/v/release/ek33450505/cast-agents?style=flat-square) | `brew tap ek33450505/cast-agents && brew install cast-agents` |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent agent memory with FTS5 search, relevance scoring, shared pool, semantic embeddings. Per-agent knowledge accumulation. | ![](https://img.shields.io/github/v/release/ek33450505/cast-memory?style=flat-square) | `brew tap ek33450505/cast-memory && brew install cast-memory` |
| [cast-routines](https://github.com/ek33450505/cast-routines) | Scheduled autonomous Claude Code routines via YAML + cron. Daily briefings, inbox triage, release celebration, weekly cost reports. | ![](https://img.shields.io/github/v/release/ek33450505/cast-routines?style=flat-square) | `brew tap ek33450505/cast-routines && brew install cast-routines` |
| [cast-parallel](https://github.com/ek33450505/cast-parallel) | Parallel agent execution across worktree sessions. Agent Dispatch Manifest (ADM) support. | ![](https://img.shields.io/github/v/release/ek33450505/cast-parallel?style=flat-square) | `brew tap ek33450505/cast-parallel && brew install cast-parallel` |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session-level observability — cost tracking, agent run history, token spend, event sourcing. Feeds cast.db. | ![](https://img.shields.io/github/v/release/ek33450505/cast-observe?style=flat-square) | `brew tap ek33450505/cast-observe && brew install cast-observe` |
| [cast-security](https://github.com/ek33450505/cast-security) | Security hooks and audit trails. PII redaction, parry-guard integration, compliance logging. | ![](https://img.shields.io/github/v/release/ek33450505/cast-security?style=flat-square) | `brew tap ek33450505/cast-security && brew install cast-security` |
| [cast-doctor](https://github.com/ek33450505/cast-doctor) | Read-only health check for any Claude Code install. Validates hooks, MCP servers, agent frontmatter, cast.db schema, stale memories. | ![](https://img.shields.io/github/v/release/ek33450505/cast-doctor?style=flat-square) | `brew tap ek33450505/cast-doctor && brew install cast-doctor` |
| [cast-time](https://github.com/ek33450505/cast-time) | Gives Claude Code a clock — injects local time, timezone, and a semantic time-of-day bucket at every SessionStart. | ![](https://img.shields.io/github/v/release/ek33450505/cast-time?style=flat-square) | `brew tap ek33450505/cast-time && brew install cast-time` |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard for live swarm monitoring. 4-panel real-time display (Textual framework). | ![](https://img.shields.io/github/v/release/ek33450505/cast-dash?style=flat-square) | `brew tap ek33450505/cast-dash && brew install cast-dash` |
| [cast-claudes_journal](https://github.com/ek33450505/cast-claudes_journal) | Session continuity — Claude's Journal auto-injects prior-day context via SessionStart hook. Obsidian vault sync. | ![](https://img.shields.io/github/v/release/ek33450505/cast-claudes_journal?style=flat-square) | `brew tap ek33450505/homebrew-claudes-journal && brew install claudes-journal` |
| [cast-website](https://github.com/ek33450505/cast-website) | castframework.dev — marketing site and docs portal for the CAST ecosystem. | ![](https://img.shields.io/github/v/release/ek33450505/cast-website?style=flat-square) | — |
| [cast-desktop](https://github.com/ek33450505/cast-desktop) | Tauri 2 native app — embedded PTY terminal, command palette, 11 dashboard views, Constellation 3D graph. NEW. | ![](https://img.shields.io/github/v/release/ek33450505/cast-desktop?style=flat-square) | `brew tap ek33450505/homebrew-cast-desktop && brew install cast-desktop` |
<!-- ECOSYSTEM_END -->

## License

MIT — see [LICENSE](LICENSE).
