---
name: kb-find
description: Search the AlfaEdge Outline knowledge base (docs.alfaedge.org) — setup guides, SOPs, infra notes, integrations, known Frappe bugs, product and client docs. Use BEFORE starting to build, integrate, set up, or fix anything, to check if the team already documented something similar. Also use when the user asks about internal AlfaEdge systems or says "check our docs / Outline / KB".
argument-hint: "<what to find>"
context: fork
agent: general-purpose
model: haiku
allowed-tools: mcp__plugin_alfaedge_outline__list_documents mcp__plugin_alfaedge_outline__fetch mcp__plugin_alfaedge_outline__list_collections mcp__plugin_alfaedge_outline__list_collection_documents
---

# Find docs in the AlfaEdge knowledge base

Query: $ARGUMENTS

You are READ-ONLY. Never create, edit, move, or delete anything.

## Steps

1. **Pick search terms.** Search uses AND: every word must match.
   - Use the key name only: product, vendor, service, error text (e.g. `VI`, `Vodafone Idea`, `Bifrost`).
   - Drop generic words: integration, setup, how to, guide, build, add.
2. **Search** with `list_documents` (`query` = terms, `limit` 10).
   - No good hits → retry once with a synonym or the full vendor name.
3. **Filter noise** using title, breadcrumb and `context` snippet.
   - Short terms match inside other words (`vi` → "overview"). Drop those hits.
4. **Fetch** only clearly relevant hits (max 3) with `fetch` (resource `document`).
   - Nothing clearly relevant → don't fetch; go to output.
5. Return ONLY the output below — no raw JSON, no author info, no IDs.

## Output format

```
📄 <Title>
   <Breadcrumb> · <url>
   • <key point>
   • <key point>
   • <key point, max 4>

Also related: <Title> (<url>), <Title> (<url>)   ← other decent hits, titles only
```

- Keep bullets short and concrete (commands, names, file paths, gotchas).
- Nothing relevant → reply with one line: `📭 Nothing in the KB about <topic>.`

## Auth errors

If the Outline tools are missing or return 401 / authentication errors, return only:

```
⚠️ Outline not connected. Re-run setup:
   curl -fsSL https://raw.githubusercontent.com/ArjunKrish7356/alfaedge/master/setup.sh | bash
```
