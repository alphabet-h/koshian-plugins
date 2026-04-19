#!/bin/bash
# scaffold-plugin.sh — create plugin scaffold (plugin.json + LICENSE + README + CHANGELOG)

set -euo pipefail

# Parse args
OUTPUT_DIR=""
PLUGIN_NAME=""
DESCRIPTION=""
AUTHOR=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --plugin-name) PLUGIN_NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --author) AUTHOR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

# Validate
for var in OUTPUT_DIR PLUGIN_NAME DESCRIPTION AUTHOR; do
  if [ -z "${!var}" ]; then
    echo "Error: --${var,,} is required (use kebab-case)"
    exit 2
  fi
done

YEAR=$(date +%Y)
DATE=$(date +%Y-%m-%d)

mkdir -p "$OUTPUT_DIR/.claude-plugin"

# plugin.json
cat > "$OUTPUT_DIR/.claude-plugin/plugin.json" <<EOF
{
  "name": "${PLUGIN_NAME}",
  "version": "0.1.0",
  "description": "${DESCRIPTION}",
  "author": {
    "name": "${AUTHOR}"
  }
}
EOF

# LICENSE (MIT)
cat > "$OUTPUT_DIR/LICENSE" <<EOF
MIT License

Copyright (c) ${YEAR} ${AUTHOR}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# README.md (placeholder; user is expected to flesh out)
cat > "$OUTPUT_DIR/README.md" <<EOF
# ${PLUGIN_NAME}

${DESCRIPTION}

## Installation

\`\`\`
/plugin install ${PLUGIN_NAME}
\`\`\`

## License

MIT
EOF

# CHANGELOG.md
cat > "$OUTPUT_DIR/CHANGELOG.md" <<EOF
# Changelog

## [0.1.0] - ${DATE}

### Added
- Initial release of \`${PLUGIN_NAME}\` plugin
EOF

echo "Scaffolded plugin at: $OUTPUT_DIR"
