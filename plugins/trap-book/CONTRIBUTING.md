# Contributing to trap-book

## Development Environment

- **OS**: Linux / macOS / Windows (WSL or Git Bash). PowerShell is not supported for v0.1.0.
- **Shell**: bash 4+ with `set -euo pipefail` compatibility
- **Dependencies**: `jq`, `perl`, `bats-core`, `kb-mcp` v0.1.0+

## Running Tests

```bash
# Install bats-core once
brew install bats-core   # macOS
# or: apt-get install bats  # Debian/Ubuntu

# Run all Layer-1 tests (no kb-mcp required — uses mock)
cd plugins/trap-book
bats tests/
```

## Adding Fixtures

To extend intent detection or redaction coverage, add lines to the appropriate fixture and re-run bats — no code change needed:

- `tests/fixtures/intent/positive.txt` — one per line, lines that MUST trigger inject intent
- `tests/fixtures/intent/negative.txt` — one per line, lines that must NOT trigger
- `tests/fixtures/intent/negation.txt` — resolution signals that the negation filter must cancel
- `tests/fixtures/redact/input-*.txt` + `expected-*.txt` — paired files
