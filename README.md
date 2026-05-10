# Codex LLM Wiki

This workspace implements a lightweight version of Andrej Karpathy's LLM Wiki pattern for Codex.

The idea is simple:

```text
raw/   append-only source material, including Codex session logs
wiki/  maintained Markdown knowledge compiled from raw sources and work sessions
```

## Usage

Start Codex normally from this workspace:

```bash
codex -C .
```

The project-local `.codex/config.toml` enables Codex hooks with `[features].hooks = true`, and `.codex/hooks.json` registers the project hooks:

- `SessionStart` adds wiki operating context.
- `UserPromptSubmit` appends prompts to `raw/hooks/user-prompts.jsonl`.
- `Stop` appends stop events to `raw/hooks/stops.jsonl` and forces a short wiki writeback continuation before the final answer.

The wrapper starts Codex with `--no-alt-screen -C "$ROOT"` and remains useful as a session-boundary fallback:

```bash
./scripts/codex-wiki.sh
```

## Reuse In Another Project

No package install is required. Copy the hook template into another project:

```bash
/path/to/code-wiki/scripts/install-llm-wiki.sh /path/to/your/project
```

On Windows, run the PowerShell installer from the source checkout:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\path\to\code-wiki\scripts\install-llm-wiki.ps1 C:\path\to\your\project
```

or from `cmd.exe`:

```bat
C:\path\to\code-wiki\scripts\install-llm-wiki.cmd C:\path\to\your\project
```

Then run Codex from that project:

```bash
codex -C /path/to/your/project
```

The installer copies `.codex/`, `scripts/`, `AGENTS.md`, and starter `wiki/` pages. It skips files that already exist so it does not overwrite an existing project setup. If the target already has `AGENTS.md`, `.codex/config.toml`, or `.codex/hooks.json`, merge the generated rules manually. The Windows installer creates a PowerShell-based `.codex/hooks.json` that calls `.codex/hooks/run-hook.ps1`; `install-llm-wiki.cmd` is a small wrapper around the PowerShell installer.

When the Codex session exits, the wrapper:

1. Finds the newest Codex session JSONL under `$CODEX_HOME/sessions` or `~/.codex/sessions`.
2. Copies it into `raw/codex/`.
3. Runs `scripts/wiki-maintain.sh` with that transcript, or runs it without a transcript if no new session file is found.

For one-off maintenance:

```bash
./scripts/wiki-maintain.sh raw/codex/<session>.jsonl
```

## Important Limitation

Codex hooks are suitable for automation and guardrails, but official documentation notes that not every tool path is fully interceptable. Treat the wiki hook as a practical writeback mechanism, not a security boundary.
