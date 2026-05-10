#!/usr/bin/env bash
set -euo pipefail

HOOK_NAME="${1:?hook name required}"
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$HOOK_NAME" in
  session_start)
    exec /usr/bin/env python3 "$HOOK_DIR/session_start.py"
    ;;
  user_prompt_submit)
    exec /usr/bin/env python3 "$HOOK_DIR/user_prompt_submit.py"
    ;;
  wiki_stop)
    exec /usr/bin/env python3 "$HOOK_DIR/wiki_stop.py"
    ;;
  *)
    echo "unknown hook: $HOOK_NAME" >&2
    exit 2
    ;;
esac

