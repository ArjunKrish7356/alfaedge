---
name: kb-write
description: Write a short doc into the AlfaEdge Outline Knowledge Base. When you finish something worth keeping for the team — a fixed tricky bug, setup or integration steps, a gotcha, a non-obvious config — ASK the user once, at the end of the task, "Want me to add this to the KB?". Invoke this skill ONLY after the user explicitly says yes. Never invoke it on your own.
argument-hint: "[topic]"
model: haiku
allowed-tools: mcp__plugin_alfaedge_outline__list_collection_documents mcp__plugin_alfaedge_outline__list_documents mcp__plugin_alfaedge_outline__fetch
---

# Write a doc to the Knowledge Base

Topic: $ARGUMENTS (if empty, use what was just built or discussed in this conversation)

## Hard rules

- Run only if the user explicitly asked for it, or said yes to "add this to the KB?". Otherwise stop now.

- Target is ALWAYS the **Knowledge Base** collection: `collectionId = 6b520a26-35eb-4afa-b4d8-dd947d85007a`.
  - Pass this `collectionId` on EVERY `create_document` call, including folders and nested docs.
- Only `create_document` is allowed. Never update, move, or delete. (A hook enforces this.)
- NEVER create anything before the user says yes.

## Steps

1. **Gather** — read the relevant code / conversation. Get facts, not guesses.
2. **Check for duplicates** — `list_documents` with `query` = the topic and `collectionId` = the Knowledge Base.
   - A close match exists → tell the user (title + link) and ask: create new anyway, or stop?
3. **See the tree** — `list_collection_documents` for the Knowledge Base.
4. **Pick a place**
   - Reuse an existing folder (parent doc) if it fits.
   - Otherwise propose a new folder: a short parent doc (title = area name, e.g. "Frappe", body = one line on what's inside).
   - Max 2 levels deep: `Knowledge Base › Folder › Doc`.
5. **Draft a MINIMAL doc** — markdown, no H1 (title is separate). Only the sections that apply:

   ```
   One-line summary of what this is.

   ## Why
   ## How it works / Steps
   ## Commands / Config      (code blocks)
   ## Gotchas
   ```

   - Short bullets, no fluff. Aim for under ~60 lines.
   - No secrets, tokens, passwords, or private keys — replace with `<placeholder>`.
6. **Preview and confirm** — show:

   ```
   📁 Path:   Knowledge Base › <Folder> › <Title>
   🆕 Folder: <name> (new) | existing
   📝 Doc:
   <full markdown>
   ```

   Then ask with AskUserQuestion: **Push** / **Edit** / **Cancel**.
   - Edit → apply changes, show the preview again.
   - Cancel → stop.
7. **Push** (only after "Push"):
   - New folder → `create_document` (collectionId = KB, `publish: true`), keep its id.
   - Doc → `create_document` (collectionId = KB, `parentDocumentId` = folder id, `publish: true`).
8. **Report** — the doc's title and URL.

## Auth errors

If the Outline tools are missing or return 401, tell the user to re-run setup:

```
curl -fsSL https://raw.githubusercontent.com/ArjunKrish7356/alfaedge/master/setup.sh | bash
```
