# Codex Auto Wiki

## Goal

Maintain a Markdown wiki automatically while coding with Codex, following the LLM Wiki pattern:

```text
raw/   append-only transcripts and source material
wiki/  current compiled knowledge
```

## Current Design

Codex provides a hooks framework behind the `hooks` feature flag. This workspace should use hooks as the primary automation path:

- `.codex/config.toml` enables `hooks`.
- `.codex/hooks.json` defines project-local hooks.
- `SessionStart` adds startup context reminding Codex to use the wiki.
- `UserPromptSubmit` appends submitted prompts to `raw/hooks/user-prompts.jsonl` and adds wiki context.
- `Stop` appends stop events to `raw/hooks/stops.jsonl` and asks Codex to run a wiki writeback pass before the final answer.
- `PreToolUse` and `PostToolUse` can observe supported tools, including `Bash`, `apply_patch`, and MCP tools, with some runtime limitations.
- `AGENTS.md` remains useful as a model-level writeback rule.
- `scripts/codex-wiki.sh` remains useful as a session-boundary fallback.

## Operating Command

```bash
codex -C .
```

or:

```bash
./scripts/codex-wiki.sh
```

## Maintenance Command

```bash
./scripts/wiki-maintain.sh raw/codex/<session>.jsonl
```

`scripts/wiki-maintain.sh` uses Codex, not Gemini. It invokes:

```bash
codex exec --skip-git-repo-check -C "$ROOT" "$prompt"
```

## Lint Command

```bash
./scripts/wiki-lint.sh
```

The wiki lint command is deterministic and does not use git. It reports broken internal links, adds missing or orphan pages to `wiki/index.md`, removes duplicate index links, and writes `wiki/lint-report.md`. It should not resolve knowledge conflicts, update stale facts, merge pages, or perform public-repository secret checks.

Codex should run this command when the user asks for wiki lint in Korean or English, including "lint", "lint 하자", "린트해", or "위키 린트".

## Limitation

Hooks are the right path for per-turn wiki maintenance, especially `Stop`. Official documentation notes that some tool interception is incomplete for shell paths and non-shell/non-MCP tools, so hooks should be treated as automation and guardrails rather than a perfect enforcement boundary.

The `Stop` hook uses Codex's `stop_hook_active` input to avoid an infinite continuation loop.

## Reuse

Use `scripts/install-llm-wiki.sh` to copy this setup into another project without packaging:

```bash
/path/to/code-wiki/scripts/install-llm-wiki.sh /path/to/project
```

Use `scripts/install-llm-wiki.ps1` from Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\path\to\code-wiki\scripts\install-llm-wiki.ps1 C:\path\to\project
```

`scripts/install-llm-wiki.cmd` is a Windows `cmd.exe` wrapper around the PowerShell installer.

The installers copy `.codex/`, `scripts/`, `AGENTS.md`, and starter `wiki/` pages. They skip existing files, so projects with existing Codex config should merge manually. The Windows installer writes a PowerShell-based `.codex/hooks.json` that calls `.codex/hooks/run-hook.ps1`; the Unix installer copies the repository's shell-based `.codex/hooks.json`. Both installers copy `scripts/wiki-lint.sh`.

## Repository README

`README.md` is the public quick-start for this workspace. Keep it aligned with `.codex/config.toml`, `.codex/hooks.json`, and the three scripts in `scripts/` whenever hook setup or maintenance flow changes.

## GitHub Remote

As of 2026-05-09, this workspace is published to `git@github.com:kkalrak/code-wiki.git` on the `main` branch. Do not commit generated Python cache files; `.gitignore` excludes `__pycache__/` and `*.py[cod]`.

## Public Repository Hygiene

As of 2026-05-10, the committed tree was checked for API keys, tokens, passwords, private keys, credential files, email/phone/ID-number-like patterns, and long token-like strings. No real secrets were found. Absolute local user paths were removed from docs/wiki examples because the repository is public.
