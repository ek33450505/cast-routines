#!/bin/bash
# install.sh — cast-routines installer
# Copies the runner, DB helper, CLI, and starter routine YAMLs into ~/.claude/.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CR_VERSION="$(cat "$REPO_DIR/VERSION" 2>/dev/null || echo unknown)"

if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
  C_BOLD='\033[1m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'
  C_RED='\033[0;31m'; C_RESET='\033[0m'
else
  C_BOLD='' C_GREEN='' C_YELLOW='' C_RED='' C_RESET=''
fi

_ok()   { printf "${C_GREEN}  [ok]${C_RESET} %s\n" "$*"; }
_warn() { printf "${C_YELLOW}  [warn]${C_RESET} %s\n" "$*" >&2; }
_fail() { printf "${C_RED}  [fail]${C_RESET} %s\n" "$*" >&2; exit 1; }
_step() { printf "\n${C_BOLD}%s${C_RESET}\n" "$*"; }

printf "\n${C_BOLD}cast-routines v${CR_VERSION} installer${C_RESET}\n"
printf "═════════════════════════════════════════════\n"
printf "  Schedule autonomous Claude Code routines.\n\n"

_step "Checking prerequisites..."
command -v python3 >/dev/null || _fail "python3 not found"
command -v sqlite3 >/dev/null || _warn "sqlite3 not found — routines/list and status will not work without it"
command -v crontab >/dev/null || _warn "crontab not found — cron-triggered routines will not install"
if python3 -c "import yaml" 2>/dev/null; then
  _ok "PyYAML available"
else
  _warn "python3-yaml (PyYAML) not found — install with: pip3 install pyyaml"
fi
if command -v claude >/dev/null; then
  _ok "Claude Code CLI found"
else
  _warn "claude CLI not found — install from https://install.anthropic.com"
fi

CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
ROUTINES_DIR="$CLAUDE_DIR/routines"
mkdir -p "$SCRIPTS_DIR" "$ROUTINES_DIR"
_ok "~/.claude/{scripts,routines}/ ready"

_step "Installing helper scripts..."
cp "$REPO_DIR/scripts/cast-routine-runner.sh" "$SCRIPTS_DIR/"
chmod 750 "$SCRIPTS_DIR/cast-routine-runner.sh"
_ok "cast-routine-runner.sh → ~/.claude/scripts/"
cp "$REPO_DIR/scripts/cast-db-routines.py" "$SCRIPTS_DIR/"
chmod 750 "$SCRIPTS_DIR/cast-db-routines.py"
_ok "cast-db-routines.py → ~/.claude/scripts/"

_step "Installing starter routine templates..."
COPIED=0
for f in "$REPO_DIR"/routines/*.yaml; do
  name="$(basename "$f")"
  if [ -f "$ROUTINES_DIR/$name" ]; then
    _warn "skipped (already exists): $name"
  else
    cp "$f" "$ROUTINES_DIR/"
    COPIED=$((COPIED + 1))
  fi
done
_ok "$COPIED starter routines copied → ~/.claude/routines/"

_step "Installing CLI shim (cast-routines)..."
BIN_TARGET="${CAST_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$BIN_TARGET"
cp "$REPO_DIR/bin/cast-routines" "$BIN_TARGET/cast-routines"
chmod 755 "$BIN_TARGET/cast-routines"
_ok "cast-routines → $BIN_TARGET/cast-routines"

if [[ ":$PATH:" != *":$BIN_TARGET:"* ]]; then
  _warn "$BIN_TARGET is not on your PATH — add it to your shell rc to use \`cast-routines\` directly."
fi

printf "\n${C_BOLD}═════════════════════════════════════════════${C_RESET}\n"
printf "${C_GREEN}cast-routines v${CR_VERSION} installed.${C_RESET}\n\n"
printf "  CLI:        $BIN_TARGET/cast-routines\n"
printf "  Helpers:    ~/.claude/scripts/cast-routine-runner.sh, cast-db-routines.py\n"
printf "  Routines:   ~/.claude/routines/  (%d starter templates)\n\n" "$COPIED"
printf "${C_BOLD}Try it:${C_RESET}\n"
printf "  cast-routines list\n"
printf "  cast-routines validate ~/.claude/routines/daily-briefing.yaml\n\n"
