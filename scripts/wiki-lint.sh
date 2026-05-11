#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY="$(date +%F)"

mkdir -p "$ROOT/wiki"

python3 - "$ROOT" "$TODAY" <<'PY'
import os
import re
import sys
from pathlib import Path
from urllib.parse import unquote

root = Path(sys.argv[1])
today = sys.argv[2]
wiki = root / "wiki"
index = wiki / "index.md"
report = wiki / "lint-report.md"

wiki.mkdir(parents=True, exist_ok=True)

if not index.exists():
    index.write_text(
        "# Wiki Index\n\n"
        "This wiki is maintained by Codex from raw sources and work sessions.\n\n"
        "## Core Pages\n\n"
        "- [Activity Log](activity-log.md)\n",
        encoding="utf-8",
    )

md_files = sorted(
    path for path in wiki.glob("*.md")
    if path.name != "lint-report.md"
)

link_re = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
heading_re = re.compile(r"^#\s+(.+?)\s*$", re.MULTILINE)
bullet_link_re = re.compile(r"^\s*-\s+\[[^\]]+\]\(([^)]+\.md(?:#[^)]+)?)\)\s*$")


def normalize_target(raw: str) -> str | None:
    target = raw.strip()
    if not target or target.startswith("#"):
        return None
    lowered = target.lower()
    if lowered.startswith(("http://", "https://", "mailto:", "tel:")):
        return None
    target = target.split("#", 1)[0].split("?", 1)[0].strip()
    if not target or not target.endswith(".md"):
        return None
    return unquote(target)


def display_title(path: Path) -> str:
    text = path.read_text(encoding="utf-8", errors="replace")
    match = heading_re.search(text)
    if match:
        return match.group(1).strip()
    return path.stem.replace("-", " ").title()


def rel_from_wiki(path: Path) -> str:
    return path.relative_to(wiki).as_posix()


existing_pages = {rel_from_wiki(path): path for path in md_files}
existing_page_names = set(existing_pages)
links_by_source: dict[str, list[str]] = {}
broken_links: list[tuple[str, str]] = []
incoming: dict[str, set[str]] = {name: set() for name in existing_page_names}

for source in md_files:
    source_rel = rel_from_wiki(source)
    text = source.read_text(encoding="utf-8", errors="replace")
    links: list[str] = []
    for match in link_re.finditer(text):
        target = normalize_target(match.group(1))
        if target is None:
            continue
        resolved = (source.parent / target).resolve()
        try:
            target_rel = resolved.relative_to(wiki.resolve()).as_posix()
        except ValueError:
            broken_links.append((source_rel, target))
            links.append(target)
            continue
        links.append(target_rel)
        if target_rel in incoming:
            incoming[target_rel].add(source_rel)
        else:
            broken_links.append((source_rel, target))
    links_by_source[source_rel] = links

index_text = index.read_text(encoding="utf-8", errors="replace")
index_lines = index_text.splitlines()
deduped_lines: list[str] = []
seen_index_targets: set[str] = set()
duplicate_index_links: list[str] = []

for line in index_lines:
    match = bullet_link_re.match(line)
    if match:
        target = normalize_target(match.group(1))
        if target in seen_index_targets:
            duplicate_index_links.append(target)
            continue
        if target:
            seen_index_targets.add(target)
    deduped_lines.append(line)

if deduped_lines != index_lines:
    index_lines = deduped_lines
    index_text = "\n".join(index_lines).rstrip() + "\n"

indexed_pages = {
    normalize_target(match.group(1))
    for line in index_lines
    for match in [bullet_link_re.match(line)]
    if match and normalize_target(match.group(1))
}

missing_from_index = sorted(
    name for name in existing_page_names
    if name not in indexed_pages and name != "index.md"
)

orphan_pages = sorted(
    name for name in existing_page_names
    if name not in {"index.md"} and not incoming.get(name)
)

pages_to_add = sorted(set(missing_from_index) | set(orphan_pages))

if pages_to_add:
    if "## Lint Discovered Pages" not in index_text:
        index_text = index_text.rstrip() + "\n\n## Lint Discovered Pages\n"
    if not index_text.endswith("\n"):
        index_text += "\n"
    for page in pages_to_add:
        title = display_title(existing_pages[page])
        link_line = f"- [{title}]({page})"
        if link_line not in index_text.splitlines():
            index_text += f"{link_line}\n"

index.write_text(index_text.rstrip() + "\n", encoding="utf-8")

def section(title: str, items: list[str]) -> str:
    if not items:
        return f"## {title}\n\nNone.\n"
    return f"## {title}\n\n" + "\n".join(f"- {item}" for item in items) + "\n"

report_body = [
    "# Wiki Lint Report",
    "",
    f"Date: {today}",
    "",
    "Scope: deterministic wiki structure lint only. This check does not inspect git state, commits, remotes, or public-repository hygiene.",
    "",
    section(
        "Automatic Fixes Applied",
        [
            *(f"Removed duplicate index link to `{target}`." for target in duplicate_index_links),
            *(f"Added `{page}` to `wiki/index.md`." for page in pages_to_add),
        ],
    ),
    section(
        "Broken Internal Links",
        [f"`{source}` links to missing `{target}`." for source, target in broken_links],
    ),
    section(
        "Index Missing Pages",
        [f"`{page}` was missing from `wiki/index.md` before lint." for page in missing_from_index],
    ),
    section(
        "Orphan Pages",
        [f"`{page}` had no incoming wiki links before lint." for page in orphan_pages],
    ),
    section(
        "Duplicate Index Links",
        [f"`{target}` appeared more than once in `wiki/index.md`." for target in duplicate_index_links],
    ),
]

report.write_text("\n".join(report_body).rstrip() + "\n", encoding="utf-8")

print(f"Wiki lint complete: {report.relative_to(root)}")
if pages_to_add:
    print(f"Updated index entries: {len(pages_to_add)}")
if duplicate_index_links:
    print(f"Removed duplicate index links: {len(duplicate_index_links)}")
if broken_links:
    print(f"Broken internal links: {len(broken_links)}")
PY
