# Security Policy

## Supported Versions

| Version | Support Status |
|---|---|
| 0.1.x | Full support — security fixes backported |
| < 0.1 | No longer supported |

## Reporting a Vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

Report privately using [GitHub Security Advisories](https://github.com/ek33450505/cast-routines/security/advisories/new).

### What to Include

- **Version** — output of `cat ~/Projects/personal/cast-routines/VERSION`
- **Operating system** — macOS version (`sw_vers`) or Linux distro
- **Which file** — e.g., `install.sh`, `bin/cast-routines`, `scripts/cast-routine-runner.sh`
- **Steps to reproduce** — minimal, clear reproduction steps
- **Impact** — what an attacker could do

### Response Timeline

| Severity | Acknowledgment | Fix Target |
|---|---|---|
| Critical | 48 hours | 14 days |
| High | 48 hours | 30 days |
| Medium / Low | 5 business days | Next release |

## Security Design Notes

cast-routines installs a CLI and a runner that can dispatch Claude Code agents on a schedule. Key design decisions:

- **Routine names are strictly validated** — `^[a-z][a-z0-9_-]{0,63}$` regex prevents path traversal in `install`, `uninstall`, `enable`, `disable`.
- **Cron expressions are validated** — `install` rejects any `trigger.value` that isn't five whitespace-separated `[0-9*,/-]+` fields.
- **No network calls from the installer** — `install.sh` and `uninstall.sh` only read/write under `$HOME/.claude/` and `$HOME/.local/bin/`.
- **Agent dispatch is delegated** — cast-routines does not contain or transmit any API keys. It invokes the Claude Code CLI which handles authentication via the user's existing credentials.
- **Cron entries are sanitized** — only the exact `bash <runner> <validated-name> --from-cron` form is appended; the routine name in the cron entry has already passed regex validation.

## Trust Model

cast-routines assumes:

- The user controls their own `~/.claude/routines/` directory. YAML configs in that directory are trusted as user input.
- The Claude Code CLI is authenticated correctly. cast-routines does not handle API keys or tokens.
- The user controls their own crontab. cast-routines appends and removes entries it owns (matched by routine name); it does not modify unrelated entries.

## Out of Scope

- Vulnerabilities in the Claude API or Anthropic services — report to [Anthropic](https://www.anthropic.com/security)
- Vulnerabilities in third-party tools (bash, Python, PyYAML, crontab, sqlite3)
- Agent behavior or output quality — these are configuration concerns, not security boundaries
- The contents of YAML configs the user authors — sanitization is the user's responsibility
