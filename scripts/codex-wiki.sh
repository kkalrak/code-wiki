#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
SESSION_DIR="$CODEX_HOME_DIR/sessions"
START_EPOCH="$(date +%s)"

mkdir -p "$ROOT/raw/codex" "$ROOT/wiki"

status=0
codex --no-alt-screen -C "$ROOT" "$@" || status=$?

latest_session=""
if [[ -d "$SESSION_DIR" ]]; then
  latest_session="$(
    find "$SESSION_DIR" -type f -name '*.jsonl' -newermt "@$START_EPOCH" -printf '%T@ %p\n' 2>/dev/null \
      | sort -nr \
      | head -1 \
      | cut -d' ' -f2- || true
  )"
fi

if [[ -n "$latest_session" && -f "$latest_session" ]]; then
  stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  dest="$ROOT/raw/codex/$stamp.jsonl"
  cp "$latest_session" "$dest"
  "$ROOT/scripts/wiki-maintain.sh" "$dest" || true
else
  "$ROOT/scripts/wiki-maintain.sh" || true
fi

exit "$status"
