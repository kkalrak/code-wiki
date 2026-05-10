#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$(pwd)}"
TARGET_ROOT="$(cd "$TARGET" && pwd)"

mkdir -p \
  "$TARGET_ROOT/.codex/hooks" \
  "$TARGET_ROOT/scripts" \
  "$TARGET_ROOT/wiki" \
  "$TARGET_ROOT/raw"

copy_file() {
  local source="$1"
  local target="$2"

  if [[ -e "$target" ]]; then
    echo "skip existing: ${target#$TARGET_ROOT/}"
    return
  fi

  cp "$source" "$target"
  echo "created: ${target#$TARGET_ROOT/}"
}

copy_file "$SOURCE_ROOT/.codex/config.toml" "$TARGET_ROOT/.codex/config.toml"
copy_file "$SOURCE_ROOT/.codex/hooks.json" "$TARGET_ROOT/.codex/hooks.json"
copy_file "$SOURCE_ROOT/.codex/hooks/run-hook.sh" "$TARGET_ROOT/.codex/hooks/run-hook.sh"
copy_file "$SOURCE_ROOT/.codex/hooks/run-hook.ps1" "$TARGET_ROOT/.codex/hooks/run-hook.ps1"
copy_file "$SOURCE_ROOT/.codex/hooks/session_start.py" "$TARGET_ROOT/.codex/hooks/session_start.py"
copy_file "$SOURCE_ROOT/.codex/hooks/user_prompt_submit.py" "$TARGET_ROOT/.codex/hooks/user_prompt_submit.py"
copy_file "$SOURCE_ROOT/.codex/hooks/wiki_stop.py" "$TARGET_ROOT/.codex/hooks/wiki_stop.py"
copy_file "$SOURCE_ROOT/scripts/wiki-maintain.sh" "$TARGET_ROOT/scripts/wiki-maintain.sh"
copy_file "$SOURCE_ROOT/scripts/codex-wiki.sh" "$TARGET_ROOT/scripts/codex-wiki.sh"
copy_file "$SOURCE_ROOT/scripts/install-llm-wiki.ps1" "$TARGET_ROOT/scripts/install-llm-wiki.ps1"
copy_file "$SOURCE_ROOT/scripts/install-llm-wiki.cmd" "$TARGET_ROOT/scripts/install-llm-wiki.cmd"
copy_file "$SOURCE_ROOT/AGENTS.md" "$TARGET_ROOT/AGENTS.md"
copy_file "$SOURCE_ROOT/wiki/index.md" "$TARGET_ROOT/wiki/index.md"
copy_file "$SOURCE_ROOT/wiki/activity-log.md" "$TARGET_ROOT/wiki/activity-log.md"
copy_file "$SOURCE_ROOT/wiki/codex-auto-wiki.md" "$TARGET_ROOT/wiki/codex-auto-wiki.md"

chmod +x \
  "$TARGET_ROOT/.codex/hooks/run-hook.sh" \
  "$TARGET_ROOT/.codex/hooks/session_start.py" \
  "$TARGET_ROOT/.codex/hooks/user_prompt_submit.py" \
  "$TARGET_ROOT/.codex/hooks/wiki_stop.py" \
  "$TARGET_ROOT/scripts/wiki-maintain.sh" \
  "$TARGET_ROOT/scripts/codex-wiki.sh"

echo
echo "LLM wiki hooks installed in: $TARGET_ROOT"
echo "Run Codex from that project with:"
echo "  codex -C \"$TARGET_ROOT\""
