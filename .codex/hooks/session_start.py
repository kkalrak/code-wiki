#!/usr/bin/env python3
import json
import os
import sys


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        event = {}

    cwd = event.get("cwd") or os.getcwd()
    wiki_index = os.path.join(cwd, "wiki", "index.md")

    if os.path.exists(wiki_index):
        message = (
            "This workspace uses an LLM Wiki. Read wiki/index.md early, "
            "treat raw/ as append-only source material, and update wiki/ "
            "with durable work facts before finalizing substantial turns."
        )
    else:
        message = (
            "This workspace may use an LLM Wiki. If wiki/ exists, use it as "
            "compiled durable context and keep it updated."
        )

    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "SessionStart",
                    "additionalContext": message,
                }
            }
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

