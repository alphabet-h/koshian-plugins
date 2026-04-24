#!/usr/bin/env bash
# lib/redact.sh
# Read stdin, emit stdout with secrets masked.
# Idempotent: running twice produces the same output.

set -euo pipefail

perl -pe '
  # Order matters: longer/more-specific patterns first
  s{-----BEGIN [A-Z ]+ PRIVATE KEY-----}{[REDACTED:private_key]}g;
  s{"private_key"\s*:\s*"-----BEGIN}{"private_key": "[REDACTED:gcp_sa]}g;
  s{AKIA[0-9A-Z]{16}}{[REDACTED:aws_access_key]}g;
  s{Bearer\s+[A-Za-z0-9_.+/=-]+}{[REDACTED:bearer]}g;
  s{eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+}{[REDACTED:jwt]}g;
  s{api[_-]?key\s*[=:]\s*\S+}{api_key=[REDACTED:api_key]}gi;
  s{password\s*[=:]\s*\S+}{password: [REDACTED:password]}gi;
'
