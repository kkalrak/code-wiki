# Codex Hook Execution Flow

## One-Time Install Into Another Project

```text
/path/to/code-wiki/scripts/install-llm-wiki.sh /path/to/project
        |
        +- .codex/config.toml
        |    `- hooks = true
        |
        +- .codex/hooks.json
        |    `- registers Codex hook events
        |
        +- .codex/hooks/*.py and run-hook.sh
        |
        +- AGENTS.md
        |
        `- wiki/, raw/, scripts/ starter structure
```

## Per-Turn Runtime Flow

```text
codex -C /path/to/project
        |
        v
SessionStart hook
        |
        `- adds wiki operating rules to Codex context
        |
        v
User enters a prompt
        |
        v
UserPromptSubmit hook
        |
        +- appends prompt to raw/hooks/user-prompts.jsonl
        `- adds wiki read/write reminder to context
        |
        v
Codex performs the requested work
        |
        +- reads and edits files
        +- runs commands or tests
        `- prepares the answer
        |
        v
Stop hook
        |
        +- appends stop event to raw/hooks/stops.jsonl
        |
        +- stop_hook_active == false?
        |       |
        |       `- returns decision="block"
        |          and tells Codex to run a wiki writeback pass
        |
        v
Codex updates wiki/
        |
        +- updates wiki/activity-log.md
        +- updates a related topic page
        `- updates wiki/index.md if needed
        |
        v
Stop hook runs again
        |
        +- stop_hook_active == true?
        |       |
        |       `- returns continue=false
        |
        v
Final answer is shown
```

## Loop Guard

The key control point is the `Stop` hook:

```text
Normal answer stop attempt
    |
    v
Stop hook blocks once
    |
    v
Codex performs wiki writeback
    |
    v
Second stop attempt
    |
    v
stop_hook_active=true, so the hook allows completion
```

This inserts wiki maintenance into every turn while avoiding an infinite continuation loop.
