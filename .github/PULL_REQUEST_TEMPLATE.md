## Description

<!-- What does this PR change and why? -->

## Checklist

- [ ] `bash install.sh && bash uninstall.sh` round-trip clean
- [ ] BATS tests pass: `bats tests/`
- [ ] `bash -n bin/cast-routines install.sh uninstall.sh scripts/*.sh` — all syntax-check
- [ ] `cast-routines validate` passes on every new/modified `routines/*.yaml`
- [ ] No hardcoded paths — `$HOME` / `~/` used
- [ ] `CHANGELOG.md` updated for user-visible changes
