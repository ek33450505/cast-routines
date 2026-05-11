#!/bin/bash
# uninstall.sh — remove cast-routines from ~/.claude/ and the CLI shim.
# Routine YAMLs in ~/.claude/routines/ are PRESERVED — they're your config, not ours.
set -euo pipefail

if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
  C_BOLD='\033[1m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'; C_RESET='\033[0m'
else
  C_BOLD='' C_GREEN='' C_YELLOW='' C_RESET=''
fi
_ok()   { printf "${C_GREEN}  [ok]${C_RESET} %s\n" "$*"; }
_warn() { printf "${C_YELLOW}  [warn]${C_RESET} %s\n" "$*" >&2; }
_step() { printf "\n${C_BOLD}%s${C_RESET}\n" "$*"; }

printf "\n${C_BOLD}cast-routines uninstaller${C_RESET}\n"
printf "═════════════════════════════════════════════\n\n"

_step "Removing helper scripts..."
rm -f "$HOME/.claude/scripts/cast-routine-runner.sh" && _ok "removed cast-routine-runner.sh"
rm -f "$HOME/.claude/scripts/cast-db-routines.py"    && _ok "removed cast-db-routines.py"

_step "Removing CLI shim..."
for d in "$HOME/.local/bin" "/usr/local/bin"; do
  if [ -f "$d/cast-routines" ]; then
    rm -f "$d/cast-routines" && _ok "removed $d/cast-routines"
  fi
done

_warn "Your routine YAMLs in ~/.claude/routines/ were preserved. Remove them manually if desired."
_warn "Cron entries you installed via 'cast-routines install' remain — run 'crontab -e' to inspect or remove."

printf "\n${C_GREEN}cast-routines uninstalled.${C_RESET}\n\n"
exit 0
