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
    raw_path = os.path.join(cwd, "raw", "hooks", "user-prompts.jsonl")
    append_jsonl(
        raw_path,
        {
            "recorded_at": dt.datetime.now(dt.timezone.utc).isoformat(),
            "event": "UserPromptSubmit",
            "session_id": event.get("session_id"),
            "turn_id": event.get("turn_id"),
            "prompt": event.get("prompt"),
        },
    )

    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": (
                        "Use the LLM Wiki when relevant. Before the final answer, "
                        "make sure durable decisions and work facts are reflected "
                        "in wiki/."
                    ),
                }
            }
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

