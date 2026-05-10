# LLM Wiki Operating Rule

This workspace is an LLM-maintained wiki. Treat `raw/` as append-only source material and `wiki/` as the current compiled understanding.

Before finalizing any substantial Codex task in this workspace:

1. Read `wiki/index.md` if it exists.
2. Capture durable decisions, implementation facts, commands, failures, fixes, and user preferences into `wiki/`.
3. Prefer updating an existing topic page over creating a near-duplicate page.
4. Keep wiki pages concise, source-grounded, and dated where the fact depends on time.
5. Do not store secrets, tokens, private credentials, or unrelated terminal noise.

Minimum writeback for a normal coding turn:

- Update `wiki/activity-log.md` with the date, user intent, actions taken, files changed, and verification.
- Update or create one relevant topic page when the turn establishes reusable knowledge.
- Update `wiki/index.md` when a new page is created.

The wiki is not a transcript. It is the maintained state that future Codex sessions should read first.
