# Activity Log

Chronological record of durable work sessions. Keep entries concise and link to topic pages when useful.

## 2026-05-06

- Bootstrapped this workspace as a Codex-maintained LLM Wiki.
- Added `AGENTS.md` writeback rules so Codex updates `wiki/` before finalizing substantial work.
- Added `scripts/codex-wiki.sh` to run Codex and trigger post-session wiki maintenance.
- Added `scripts/wiki-maintain.sh` to compile Codex session transcripts from `raw/codex/` into concise wiki updates.

## 2026-05-07

- Verified that current official Codex documentation includes a hooks framework behind the hooks feature flag.
- Added project-local `.codex/config.toml` and `.codex/hooks.json`.
- Added `SessionStart`, `UserPromptSubmit`, and `Stop` hook scripts under `.codex/hooks/`.
- Configured `Stop` to force a concise wiki writeback continuation once per turn and use `stop_hook_active` to avoid recursion.
- Verified `hooks.json` with `python3 -m json.tool`, compiled hook scripts with `python3 -m py_compile`, and tested sample `Stop`/`UserPromptSubmit` inputs.
- Made hook commands project-portable through `.codex/hooks/run-hook.sh` instead of hardcoded absolute workspace paths.
- Added `scripts/install-llm-wiki.sh` to copy the setup into other projects without packaging.

## 2026-05-08

- Added `wiki/codex-hook-execution-flow.md` to preserve the install-time and per-turn hook execution sequence.
- Linked the new execution-flow page from `wiki/index.md`.

## 2026-05-09

- Replaced the deprecated hook feature flag in `.codex/config.toml` with `[features].hooks = true` after Codex emitted the deprecation warning.
- Updated hook topic pages to describe the current `hooks` feature flag.
- Verified no remaining deprecated hook feature flag references in workspace files.
- Reviewed and updated `README.md` so the hook feature flag, registered hook events, installer behavior, and wrapper fallback flow match the current files.
- Verified `README.md` against `.codex/config.toml`, `.codex/hooks.json`, `scripts/codex-wiki.sh`, `scripts/install-llm-wiki.sh`, and `scripts/wiki-maintain.sh`; ran `bash -n` on the shell scripts.
- Added Windows install support with `.codex/hooks/run-hook.ps1`, `scripts/install-llm-wiki.ps1`, and `scripts/install-llm-wiki.cmd`.
- Updated `README.md`, `install.txt`, and `wiki/codex-auto-wiki.md` with Windows PowerShell install usage.
- Initialized the workspace as a git repository for `git@github.com:kkalrak/code-wiki.git`, added `.gitignore`, and prepared the full wiki/hook/install file set for the first `main` branch push.

## 2026-05-10

- Audited the committed public repository tree for API keys, tokens, passwords, private keys, credential files, email/phone/ID-number-like patterns, and long token-like strings.
- Found no real secrets; found absolute local workspace path examples and replaced them with generic `/path/to/code-wiki` examples.
