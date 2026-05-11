---
name: Bug report
about: cast-routines doing the wrong thing
labels: bug
---

## What happened

<!-- Brief description -->

## What you expected

<!-- What should have happened? -->

## To reproduce

```bash
# Exact commands
```

## Environment

- cast-routines version: `cat $(brew --prefix cast-routines 2>/dev/null || echo .)/VERSION`
- OS: `sw_vers` (macOS) or `lsb_release -a` (Linux)
- bash version: `bash --version | head -1`
- python3 version: `python3 --version`
- PyYAML installed? `python3 -c "import yaml; print(yaml.__version__)"`

## Routine YAML (if applicable)

```yaml
# Paste the YAML that triggered the issue
```

## Cron / crontab context (if applicable)

```
# crontab -l output, redacted as needed
```
