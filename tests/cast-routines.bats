#!/usr/bin/env bats
#
# Focused standalone tests for cast-routines.
#
# These tests exercise the public CLI surface (bin/cast-routines) and the
# starter YAML templates. They do NOT require the full CAST framework, but
# they do require PyYAML (the validate command parses YAML).

REPO_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
CLI="$REPO_DIR/bin/cast-routines"

setup() {
  export ORIG_HOME="$HOME"
  HOME="$(mktemp -d)"
  export HOME
  mkdir -p "$HOME/.claude/scripts" "$HOME/.claude/routines" "$HOME/.local/bin"

  # Point CLI at the in-repo helper scripts (the script auto-resolves these)
  export CAST_DB_PATH="$BATS_TEST_TMPDIR/test-routines-$$.db"
  export CAST_ROUTINES_DIR="$HOME/.claude/routines"
  export CAST_SCRIPTS_DIR="$HOME/.claude/scripts"
  # Stub crontab so install doesn't touch the user's real crontab
  export CAST_CRONTAB_CMD="$BATS_TEST_TMPDIR/fake-crontab.sh"
  cat > "$CAST_CRONTAB_CMD" <<'EOF'
#!/bin/bash
# fake crontab — records args, treats stdin as new content
LOG="${FAKE_CRONTAB_LOG:-/tmp/fake-crontab.log}"
ARGS="$*"
if [[ "$ARGS" == "-l" ]]; then
  [ -f "${FAKE_CRONTAB_FILE:-/tmp/fake-crontab.txt}" ] && cat "${FAKE_CRONTAB_FILE:-/tmp/fake-crontab.txt}" || true
elif [[ "$ARGS" == "-" ]]; then
  cat > "${FAKE_CRONTAB_FILE:-/tmp/fake-crontab.txt}"
fi
EOF
  chmod +x "$CAST_CRONTAB_CMD"
  export FAKE_CRONTAB_FILE="$BATS_TEST_TMPDIR/fake-crontab.txt"
  : > "$FAKE_CRONTAB_FILE"
}

teardown() {
  rm -f "$CAST_DB_PATH" "$FAKE_CRONTAB_FILE"
  rm -rf "$HOME"
  HOME="$ORIG_HOME"
  export HOME
}

# ── Sanity ───────────────────────────────────────────────────────────────────

@test "CLI script is executable" {
  [ -x "$CLI" ]
}

@test "version subcommand prints VERSION" {
  run bash "$CLI" version
  [ "$status" -eq 0 ]
  [[ "$output" == *"cast-routines v"* ]]
}

@test "help / no-args prints usage" {
  run bash "$CLI" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: cast-routines"* ]]
}

@test "unknown env shows up in help" {
  run bash "$CLI" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"CAST_DB_PATH"* ]]
  [[ "$output" == *"CAST_ROUTINES_DIR"* ]]
}

# ── YAML validate ────────────────────────────────────────────────────────────

@test "validate fails when YAML path is missing" {
  run bash "$CLI" validate
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage: cast-routines validate"* ]]
}

@test "validate fails when YAML file does not exist" {
  run bash "$CLI" validate /tmp/does-not-exist-routine.yaml
  [ "$status" -ne 0 ]
  [[ "$output" == *"YAML file not found"* ]]
}

@test "validate passes for a well-formed routine YAML" {
  cat > "$BATS_TEST_TMPDIR/good.yaml" <<'YAML'
name: test-routine
description: "Test routine"
trigger:
  type: cron
  value: "0 9 * * *"
agent: morning-briefing
prompt_template: "Run the briefing."
output_dir: "~/.claude/routines-output/test"
enabled: true
YAML
  run bash "$CLI" validate "$BATS_TEST_TMPDIR/good.yaml"
  [ "$status" -eq 0 ]
  [[ "$output" == *"OK: test-routine"* ]]
}

@test "validate reports missing required fields" {
  cat > "$BATS_TEST_TMPDIR/bad.yaml" <<'YAML'
name: bad-routine
YAML
  run bash "$CLI" validate "$BATS_TEST_TMPDIR/bad.yaml"
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing required field"* ]]
}

@test "validate requires trigger.value when trigger.type is cron" {
  cat > "$BATS_TEST_TMPDIR/no-cron-value.yaml" <<'YAML'
name: no-cron-value
trigger:
  type: cron
agent: morning-briefing
prompt_template: "test"
output_dir: "/tmp/out"
YAML
  run bash "$CLI" validate "$BATS_TEST_TMPDIR/no-cron-value.yaml"
  [ "$status" -ne 0 ]
  [[ "$output" == *"trigger.value"* ]]
}

@test "validate skips agent-existence check when CAST_AGENTS_DIR is unset" {
  unset CAST_AGENTS_DIR
  cat > "$BATS_TEST_TMPDIR/unknown-agent.yaml" <<'YAML'
name: unknown-agent-test
trigger:
  type: manual
agent: nonexistent-agent
prompt_template: "test"
output_dir: "/tmp/out"
YAML
  run bash "$CLI" validate "$BATS_TEST_TMPDIR/unknown-agent.yaml"
  [ "$status" -eq 0 ]
}

@test "validate enforces agent-existence check when CAST_AGENTS_DIR is set" {
  mkdir -p "$BATS_TEST_TMPDIR/agents"
  export CAST_AGENTS_DIR="$BATS_TEST_TMPDIR/agents"
  cat > "$BATS_TEST_TMPDIR/missing-agent.yaml" <<'YAML'
name: missing-agent-test
trigger:
  type: manual
agent: nonexistent-agent
prompt_template: "test"
output_dir: "/tmp/out"
YAML
  run bash "$CLI" validate "$BATS_TEST_TMPDIR/missing-agent.yaml"
  [ "$status" -ne 0 ]
  [[ "$output" == *"agent not found"* ]]
}

# ── Starter templates ────────────────────────────────────────────────────────

@test "every shipped routines/*.yaml passes validate" {
  unset CAST_AGENTS_DIR
  for f in "$REPO_DIR"/routines/*.yaml; do
    run bash "$CLI" validate "$f"
    if [ "$status" -ne 0 ]; then
      echo "FAILED: $(basename "$f")"
      echo "$output"
      return 1
    fi
  done
}

@test "ships exactly the expected starter templates" {
  count="$(ls "$REPO_DIR"/routines/*.yaml | wc -l | tr -d ' ')"
  [ "$count" -ge 10 ]
}

# ── Routine-name validation ──────────────────────────────────────────────────

@test "uninstall rejects routine names with path traversal" {
  run bash "$CLI" uninstall "../etc/passwd"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid routine name"* ]]
}

@test "uninstall rejects routine names with shell metacharacters" {
  run bash "$CLI" uninstall "foo; rm -rf /"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid routine name"* ]]
}

@test "uninstall rejects empty routine name" {
  run bash "$CLI" uninstall
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage: cast-routines uninstall"* ]]
}

# ── Subprocess guard ─────────────────────────────────────────────────────────

@test "CLI exits 0 silently under CLAUDE_SUBPROCESS=1" {
  run env CLAUDE_SUBPROCESS=1 bash "$CLI" version
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ── Install script syntax ────────────────────────────────────────────────────

@test "install.sh passes bash -n" {
  run bash -n "$REPO_DIR/install.sh"
  [ "$status" -eq 0 ]
}

@test "uninstall.sh passes bash -n" {
  run bash -n "$REPO_DIR/uninstall.sh"
  [ "$status" -eq 0 ]
}

@test "bin/cast-routines passes bash -n" {
  run bash -n "$CLI"
  [ "$status" -eq 0 ]
}
