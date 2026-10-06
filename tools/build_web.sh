#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
godot_bin="${GODOT_BIN:-.tools/Godot.app/Contents/MacOS/Godot}"
if [[ ! -x "$godot_bin" ]]; then
  godot_bin="$(command -v godot || true)"
fi
if [[ -z "$godot_bin" ]]; then
  echo "Install Godot 4.5.1 Standard (without .NET), then set GODOT_BIN to its executable." >&2
  exit 1
fi
if [[ "$("$godot_bin" --version)" == *mono* ]]; then
  echo "Web export requires Godot Standard, not the .NET editor." >&2
  exit 1
fi
mkdir -p .tools builds/web
if [[ ! -f .tools/web_nothreads_release.zip || ! -f .tools/web_nothreads_debug.zip ]]; then
  python3 tools/fetch_web_templates.py
fi
"$godot_bin" --headless --editor --path . --import
"$godot_bin" --headless --path . --export-release Web
echo "Ready: builds/web/index.html"
