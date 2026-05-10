#!/usr/bin/env python3
import datetime as dt
import json
import os
import sys


def append_jsonl(path: str, payload: dict) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False, sort_keys=True) + "\n")


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        event = {}

    cwd = event.get("cwd") or os.getcwd()
    raw_path = os.path.join(cwd, "raw", "hooks", "stops.jsonl")
    append_jsonl(
        raw_path,
        {
            "recorded_at": dt.datetime.now(dt.timezone.utc).isoformat(),
            "event": "Stop",
            "session_id": event.get("session_id"),
            "turn_id": event.get("turn_id"),
            "stop_hook_active": event.get("stop_hook_active"),
            "last_assistant_message": event.get("last_assistant_message"),
        },
    )

    if event.get("stop_hook_active"):
        print(json.dumps({"continue": False}))
        return 0

    reason = (
        "Run the LLM Wiki writeback pass before finalizing this turn. "
        "Read wiki/index.md and AGENTS.md. Update wiki/activity-log.md with "
        "today's user intent, actions taken, files changed, and verification. "
        "Update wiki/codex-auto-wiki.md or another focused topic page if this "
        "turn created reusable knowledge. Do not copy secrets or raw transcript "
        "noise. Keep changes concise, then provide the final answer."
    )

    print(json.dumps({"decision": "block", "reason": reason}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

