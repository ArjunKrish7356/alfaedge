---
name: kb-find
description: Search the AlfaEdge Outline knowledge base (docs.alfaedge.org) for internal team docs — setup guides, SOPs, infra notes, known Frappe bugs, product and client docs — and return a short summary with links. Use when the user asks about internal AlfaEdge systems, processes, or past notes, or says "check our docs / Outline / KB".
argument-hint: "<what to find>"
context: fork
agent: general-purpose
model: sonnet
allowed-tools: mcp__plugin_alfaedge_outline__list_documents mcp__plugin_alfaedge_outline__fetch mcp__plugin_alfaedge_outline__list_collections mcp__plugin_alfaedge_outline__list_collection_documents
---

# Find docs in the AlfaEdge knowledge base

Query: $ARGUMENTS

You are READ-ONLY. Never create, edit, move, or delete anything.

## Steps

1. Search with `list_documents` (`query` = the key terms, `limit` 10).
   - No good hits → retry once with synonyms or fewer words.
2. Pick the 1–3 most relevant results (use the title, breadcrumb, and `context` snippet).
3. `fetch` each one (resource `document`) to read the full text.
4. Return ONLY the output below — no raw JSON, no author info, no IDs.

## Output format

```
📄 <Title>
   <Breadcrumb> · <url>
   • <key point>
   • <key point>
   • <key point, max 4>

📄 <Title>
   ...

Also related: <Title> (<url>), <Title> (<url>)   ← other decent hits, titles only
```

- Keep bullets short and concrete (commands, names, steps).
- If nothing matches, say so and list the closest 3 titles.

## Auth errors

If the Outline tools are missing or return 401 / authentication errors, return only:

```
⚠️ Outline not connected.
   1. Create an API key: https://docs.alfaedge.org → Settings → API
   2. Run /plugin → alfaedge → Configure → paste the key
   3. Run /reload-plugins
```
