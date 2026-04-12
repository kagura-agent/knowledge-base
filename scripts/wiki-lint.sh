#!/usr/bin/env bash
# Wiki lint: check broken [[wikilinks]] and orphan pages
set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Broken [[wikilinks]] ==="
broken=0
# Extract all [[links]] from all md files, check if target exists
grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR/cards/" "$WIKI_DIR/projects/" 2>/dev/null | sort -u | while read -r link; do
  slug="$(echo "$link" | sed 's/\[\[//;s/\]\]//' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
  if [ ! -f "$WIKI_DIR/cards/$slug.md" ] && [ ! -f "$WIKI_DIR/projects/$slug.md" ]; then
    echo "  BROKEN: $link → $slug.md not found"
  fi
done

echo ""
echo "=== Orphan pages (not linked from any other page) ==="
# Collect all slugs, check if they appear as [[slug]] anywhere
for f in "$WIKI_DIR/cards/"*.md "$WIKI_DIR/projects/"*.md; do
  [ -f "$f" ] || continue
  slug="$(basename "$f" .md)"
  # Check if this slug appears as [[slug]] in any other file
  if ! grep -rlq "\[\[$slug\]\]\|\[\[$(echo "$slug" | tr '-' ' ')\]\]" "$WIKI_DIR/cards/" "$WIKI_DIR/projects/" 2>/dev/null | grep -vq "^$f$" 2>/dev/null; then
    # Double check: exclude self-references
    refs=$(grep -rl "\[\[$slug\]\]" "$WIKI_DIR/cards/" "$WIKI_DIR/projects/" 2>/dev/null | grep -v "^$f$" | wc -l)
    if [ "$refs" -eq 0 ]; then
      echo "  ORPHAN: $(basename "$f")"
    fi
  fi
done

echo ""
echo "=== Stats ==="
total_links=$(grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR/cards/" "$WIKI_DIR/projects/" 2>/dev/null | wc -l)
unique_links=$(grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR/cards/" "$WIKI_DIR/projects/" 2>/dev/null | sort -u | wc -l)
echo "Total wikilinks: $total_links ($unique_links unique)"
