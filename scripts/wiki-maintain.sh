#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TRANSCRIPT="${1:-}"
TODAY="$(date +%F)"

mkdir -p "$ROOT/raw/codex" "$ROOT/wiki"

if [[ ! -f "$ROOT/wiki/index.md" ]]; then
  cat > "$ROOT/wiki/index.md" <<'EOF'
# Wiki Index

This wiki is maintained by Codex from raw sources and work sessions.

## Core Pages

- [Activity Log](activity-log.md)
EOF
fi

if [[ ! -f "$ROOT/wiki/activity-log.md" ]]; then
  cat > "$ROOT/wiki/activity-log.md" <<'EOF'
# Activity Log

Chronological record of durable work sessions. Keep entries concise and link to topic pages when useful.
EOF
fi

prompt="You are maintaining an LLM Wiki for this Codex workspace.

Date: $TODAY
Workspace: $ROOT
Transcript path: ${TRANSCRIPT:-none}

Follow AGENTS.md exactly. Update wiki/ from the latest Codex session if a transcript is available. If no transcript is available, inspect the current workspace and make only minimal bootstrap updates.

Rules:
- Treat raw/ as append-only.
- Treat wiki/ as compiled current knowledge, not a transcript dump.
- Update wiki/activity-log.md.
- Update wiki/index.md if pages are created.
- Create focused topic pages only for reusable knowledge.
- Do not include secrets, credentials, or irrelevant terminal noise.
- Keep changes concise.

Return a short summary of wiki files changed."

codex exec --skip-git-repo-check -C "$ROOT" "$prompt"
