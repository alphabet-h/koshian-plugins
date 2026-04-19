#!/bin/bash
# scaffold-plugin.sh — create plugin scaffold (plugin.json + LICENSE + README + CHANGELOG)
#
# All user-supplied values are passed into Python via environment variables so
# heredoc / shell expansion cannot inject commands, and so multibyte characters
# survive intact on Windows/Git Bash + Python 3.

set -euo pipefail

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

require_arg() {
  local var_name="$1" flag="$2"
  if [ -z "${!var_name}" ]; then
    echo "Error: $flag is required"
    exit 2
  fi
}
require_arg OUTPUT_DIR  --output-dir
require_arg PLUGIN_NAME --plugin-name
require_arg DESCRIPTION --description
require_arg AUTHOR      --author

YEAR=$(date +%Y)
DATE=$(date +%Y-%m-%d)

mkdir -p "$OUTPUT_DIR/.claude-plugin"

export PYTHONIOENCODING=utf-8
export PLUGIN_NAME DESCRIPTION AUTHOR YEAR DATE

# plugin.json — JSON-serialise values so quotes/backslashes/etc. are escaped safely.
python -c "
import json, os, sys
data = {
    'name': os.environ['PLUGIN_NAME'],
    'version': '0.1.0',
    'description': os.environ['DESCRIPTION'],
    'author': {'name': os.environ['AUTHOR']},
}
sys.stdout.buffer.write((json.dumps(data, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
" > "$OUTPUT_DIR/.claude-plugin/plugin.json"

# LICENSE (MIT) — literal template, only YEAR / AUTHOR substituted via str.replace.
python -c "
import os, sys
tmpl = '''MIT License

Copyright (c) __YEAR__ __AUTHOR__

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''
out = tmpl.replace('__YEAR__', os.environ['YEAR']).replace('__AUTHOR__', os.environ['AUTHOR'])
sys.stdout.buffer.write(out.encode('utf-8'))
" > "$OUTPUT_DIR/LICENSE"

# README.md — placeholder only; user is expected to flesh out.
python -c "
import os, sys
tmpl = '''# __PLUGIN_NAME__

__DESCRIPTION__

## Installation

\`\`\`
/plugin install __PLUGIN_NAME__
\`\`\`

## License

MIT
'''
out = tmpl.replace('__PLUGIN_NAME__', os.environ['PLUGIN_NAME']).replace('__DESCRIPTION__', os.environ['DESCRIPTION'])
sys.stdout.buffer.write(out.encode('utf-8'))
" > "$OUTPUT_DIR/README.md"

# CHANGELOG.md
python -c "
import os, sys
tmpl = '''# Changelog

## [0.1.0] - __DATE__

### Added
- Initial release of \`__PLUGIN_NAME__\` plugin
'''
out = tmpl.replace('__DATE__', os.environ['DATE']).replace('__PLUGIN_NAME__', os.environ['PLUGIN_NAME'])
sys.stdout.buffer.write(out.encode('utf-8'))
" > "$OUTPUT_DIR/CHANGELOG.md"

echo "Scaffolded plugin at: $OUTPUT_DIR"
